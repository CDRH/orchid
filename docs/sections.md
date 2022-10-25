# Sections

Orchid supports different "sections" of an app utilizing the same Orchid logic
and templates for different purposes. This is primarily for an app to use
separate paths to access different groups of items from the API.

For example, you might like to have one website which searches documents by
18th century musicians, and you would like to also have additional pages which
feature a specific musician and only searches their documents. Orchid is on it!

- [Config](#config)
- [Routes](#routes)
- [Controller](#controller)
- [Canonical Links](#canonical-links)
- [Links](#links)
- [Templates](#templates)

## Config

Section configuration is defined in the main app. Section names are listed in
`config/public.yml` under the `app_options:` and `sections:` keys. Each section
uses its own API and facet configuration. This section configuration is in a
YAML file with the same name as the section inside `config/sections/`. For a
section named `letters`, the file would be `config/sections/letters.yml`. This
config file must contain the keys `api_options:` and `facets:`.

The API options here match the [API config](#api) that can be applied app-wide.
A field filter for category or subcategory is the most likely filter to be set
for a section.

The facets are a list of API fields as keys for each language. Inside that are
each field's text label and whether to display it in the search UI or not (in
addition to displaying it in the browse pages).

```yaml
default: &default

  api_options:
    # only browse and search letters
    f:
      - subcategory|Letters
    …

  facets:
    en:
      api_field_name:
        label: Text label
        display: true
      api_field_2:
        label: Other text label
        display: false
    …

test:
  <<: *default

development:
  <<: *default

production:
  <<: *default
```

## Routes

Orchid keeps the sections independent by drawing routes with their names
prefixed with the section name, e.g. `letters_item_path`. The Items controllers
routes have all been augmented to utilize these prefixes. The corresponding
templates will render links using the prefixed path name helpers so the link
URLs stay within the section.

Section routes will automatically be scoped to a sub-URI with the section name
if no scope name is passed. If `section: "foo"`, scope will be set to `"/foo"`.
They also set a default `section` parameter which is then used to set the
`@section` instance variable with the section name in the application
controller. This is used for logic in rendering templates and links. Then the
`section` parameter is immediately removed so it does not interfere with
action and template code dealing with paramaters or come through in query string
or POST parameters.

```ruby
# Section routes
scope '/letters' do
  # Other route definitions
  …
  # Only draw section-compatible Items controller routes
  # No scope passed, so automatically uses "/letters"
  Orchid::Routing.draw(section: "letters",
    routes: ["browse", "browse_facet", "item", "search"])
end

# Site-wide non-section routes
Orchid::Routing.draw
```

You'll likely need more routes alongside Orchid's routes for a section. You may
set the `defaults: { section: section }` code on the `scope` block surrounding
additional routes to make the `@section` variable available in their actions and
templates as well. All routes within the `scope` block with `defaults` will
inherit that default parameter. Routes within the block may override the block's
`defaults` if necessary.

```ruby
scope '/writings/letters', defaults: { section: "letters" } do
  get '/', to: 'letters#home', as: :letters_home
  get 'known', to: 'letters#known_letters', as: :letters_known
end
```

## Controller

When creating your own section, you are not required to add a new controller,
as all of the sections are powered by the ItemsController class out of the box.

However, you may find it helpful to add a controller if you have custom actions
or views. In order to still have access to controller methods and view helpers,
you will need to set up your controller to inherit the ItemsController:

```ruby
class InthenewseventsController < ItemsController
end
```

This means you may still use instance variables such as `@items_api` when
creating custom queries.

## Canonical Item Links

If one uses a section which segregates items but they are still included by the
non-section Orchid search, items may be accessible from multiple paths.
This could lead to display problems if sections apply different styles to items,
and it will be bad for SEO.

See the [routes documentation](/docs/routes.md#canonical-item-paths) for information
about setting up canonical item links.

## Links

Navigation links in the site header are not integrated with section
pages. The Browse and Search links go to the non-section pages regardless of
whether the current page is from a section route or not. Section-specific
navigation links must be added manually. If you are linking to a section page
drawn by Orchid paths, you must use the Orchid route name prepended with
`section_`:

```html
<!-- basic Orchid path -->
<%= link_to "Browse All Items", browse_path %>

<!-- section Orchid path -->
<%= link_to "Browse Letters", letters_browse_path %>
```

If adding or modifying links within templates used by more than one section, the
application helper `prefix_path` has been added to Orchid to simplify calling
the appropriate path helper. It takes the place of where the path helper would
normally be used. The path helper's name as a string is the first parameter and
all following parameters are the same parameters to be sent to the path helper.

```html
<!-- Regular path helper use -->
<%= link_to item_path("ABC"), html_options %>

<!-- Section-compatible prefixed path use -->
<%= link_to prefix_path("item_path", "ABC"), html_options %>
```

## Templates

Orchid's views and partials are made section-compatible by calling them with
the `render_overridable` method rather than `render`. The exact same parameters
one would use with `render` are available. This replacement method checks for
section-specific template overrides in the main app's `app/views/(secton name)/`
directory before falling back to using the Orchid templates. This allows for
granular overrides of views and partials from the main app as needed without
needing to copy controller methods etc from Orchid.

# Improve this documentation

This documentation should be updated and clarified, see https://github.com/CDRH/orchid/issues/238
