# Configuration

Orchid is a Rails generator which provides basic functionality for search and
browse, while giving host applications a large amount of freedom to customize
or override behavior.

If you are just getting started, it is recommended that you learn more about
the settings from the [settings overview](/docs/configuration/settings.md)
documentation before getting started on customizing your app!

## [Settings Overview](/docs/configuration/settings.md)

- [Locating Settings](/docs/configuration/settings.md#locating-settings)
- [API Connection](/docs/configuration/settings.md#api-connection)
- [Image Server](/docs/configuration/settings.md#image-server)

## [Theming and Assets](/docs/configuration/theming.md)

Working with Views
- [Customizing Views](/docs/configuration/theming.md#customizing-views)
- [Favicon](/docs/configuration/theming.md#favicon)
- [Header and Footer](/docs/configuration/theming.md#header-and-footer)
CSS, JS, and Images
- [Global Styles](/docs/configuration/theming.md#global-styles)
- [Global JavaScript](/docs/configuration/theming.md#global-javascript)
- [Page Classes](/docs/configuration/theming.md#page-classes)
- [Add Assets by Page](/docs/configuration/theming.md#add-assets-by-page)
- [Asset Paths in SCSS](/docs/configuration/theming.md#asset-paths-in-scss)
- [Vendor Assets](/docs/configuration/theming.md#vendor-assets) (incomplete)


- [Canonical Search Item Paths](#canonical-search-item-paths)
- [Controllers and Actions](#controllers-and-actions)
- [Facets](#facets)
- [Gitignore](#gitignore)
- [Languages](#languages)
  - [Modify Languages](#modify-languages)
- [Redirects and Rewrites](#redirects-and-rewrites)
- [Routes](#routes)
  - [Scoped Routes](#scoped-routes)
- [Sections](#sections)
  - [Section Config](#section-config)
  - [Section Routes](#section-routes)
  - [Section Links](#section-links)
  - [Section Templates](#section-templates)
- [(Re)start](#restart)


### Canonical Search Item Paths
One may write their app to show items at a variety of paths, to group them
according to criteria such as category / subcategory and/or to render items
without parts of some of their IDs in the URL.

Corresponding routes must be defined the app's `config/routes.rb`, e.g.:
```ruby
…
  get 'life/:id', to: 'life#show', as: :life_item,
    constraints: { id: /chronology|shortbio|longbio|woodress/ }
  get 'writings/books/:id', to: 'items#show', as: :writings_book_item,
      constraints: { id: /(\d{4}|nf006(?:_\d{2})?|nf060|nf061)/ }
…
```

These can be utilized by writing links in views and partials to use the path
helpers `life_item_path(id: item_id)`, `writings_books_item_path(id: item_id)`.

To render links throughout the app canonically, we need the links in search
results to use these path helpers as well. This is facilitated by overriding the
helper method used to render them in `app/helpers/items_helper.rb`:
```ruby
module ItemsHelper
  include Orchid::ItemsHelper

  def search_item_link(item)
    category = item["category"].downcase
    item_id = item["identifier"][/^cat\.(.+)$/, 1]
    path = "#"
    title_display = item["title"].present? ?
      item["title"] : t("search.results.item.no_title", default: "Untitled")
    
    if category == "life"
      item_id = item_id[/^life\.(.+)$/, 1]
      path = life_item_path(id: item_id)
    elsif category == "writing"
      path = writings_book_item_path(id: item_id)
    end

    link_to title_display, path
  end
end
```

### Controllers and Actions
It is possible to override the behavior of specific actions within controllers.
To add or override a controller action, first create a file in the controllers
directory with a name ending in `_override.rb`. For example,
`app/controllers/general_override.rb`.

Then, you will need a line at the top that indicates which controller you are
working on.

```
GeneralController.class_eval do

  def action_name
    [code here]
  end

end
```

You can also override an entire controller by simply placing a file with the
controller's name in the controllers directory. For example,
`app/controllers/general_controller.rb` would take the place of the Orchid
version of this file. *This approach is not recommended.*

### Facets
Facets are API fields used to group items with similar metadata in the "Browse"
pages, e.g. items with the same value in a `category` field. For each language,
which fields are used, their order, their text labels, and their options may
vary. Each facet may also optionally:

- Function as a search filter
- Have its values from the API translated

Facet configuration is defined in `config/public.yml` for each language as:
```yaml
…
  facets:
    [language]:
      [api_field]:
        label: [display_text]
        # Optional features
        flags:
          - search_filter
          - translate
…
```

- `language` - Language code matching the code(s) set in `config/public.yml`
- `api_field` - Field name from the API. Field names may be nested (e.g.
  `creator.name`)
- `display_text` - Text displayed for the facet label for this language

The `flags:` key and its list of contained flag names may be omitted. A flag's
presence in the config file enables changes in facet use and behavior as
follows:

`search_filter` - Enables use of facets as search filters on search pages.

`translate` - Enables translation of the facet values in addition to the facet's
label. These translations may be defined inside any YAML file in
`config/locales/` with the following format for each language:

```yaml
[language]:
  facet_value:
    [api_field]:
      [field_value]: [translation]
```

- `language` - Same as above
- `api_field` - Same as above except nested field names must be written with
  underscores replacing periods
    - `field_value` - The text value returned by the API with underscores
    replacing periods, commas, and spaces
    - `translation` - The literal translated text for this particular language

As an example, imagine we have a `source` API field we don't want included in
search filters or translated. We will only show this field in English since it
won't be translated. Also imagine a `film.title` API field (made up here for
demonstation purposes) that we'd like included in search filters as well having
its label text and values translated for Spanish. Our facets configuration would
look like:

```yaml
…
  facets:
    en:
      film.title:
        label: Film Title
        flags:
          - search_filter
      source:
        label: Source
    es:
      film.title:
        label: Título de la Película
        flags:
          - search_filter
          - translate
      # Omitting source field; remember languages may vary facet use and order
…
```

If our title values are `Planes, Tranes, and Automobiles`, `Three Amigos`,
`The Out-of-Towners`, and `Roxanne` we could define our translations in
`config/locales/film_title_es.yml` as:

```yaml
es:
  facet_value:
    film_title:
      Planes__Tranes__and_Automobiles: Aviones, Trenes, y Automóviles
      Three_Amigos: Tres Amigos
      The_Out-of-Towners: Los Fuera de las Ciudades
      Roxanne: Roxanne
```





### Gitignore
Add any other files which should not be version controlled to `.gitignore`.

### Languages
By default, Orchid assumes you are developing an English-only application, but
supports the use of multiple languages. The setup generator called with `rails
g(enerate) setup` will prompt for your default language and list of all
languages.

Most of the navigation, buttons, and general wording throughout Orchid has been
pulled out into strings in `config/locales/en.yml`. Translate each entry of the
YAML file. You may toggle between languages in the application and view the
language differences.

**All translations must start with the language key or Rails will not find the
appropriate text.** An example locales file might look like:

```yaml
# config/locales/en.yml
en:
  title: Example Title
```

The `en` key in the example above is critical to finding the correct string to
display. By default, Orchid starts with an `en.yml` file and any other languages
you specified as files with similar names during setup. However, you may add
more files to help with organization. Just make sure you include the language
key before you begin creating translated strings:

```yaml
# config/locales/explore_en.yml
en:
  explore:
    ...

# config/locales/explore_es.yml
es:
  explore:
    ...
```

Please check the "Facets" section of this README for more information about how
to customize the behavior and labels of the facets by language.

Though you can add HTML to your locales files, often if you want a view with
large amounts of content you may prefer to simply work directly with views
rather than with the locales. You may do this by including the language code in
your filename.

```
app
  |-- views
          |-- explore
                    |-- mountains.html.erb
                    |-- mountains.cz.html.erb
                    |-- mountains.en.html.erb
```

In the above, if the locale were set to Czech with code `cz`, a request for the
mountains view would render `mountains.cz.html.erb`. A request for a language
without a specific view will render the general file `mountains.html.erb`. This
naming convention also applies to partials.

Please refer to the [[Scoped Routes]] documentation for more information about
adding more routes to apps which support multiple languages.

#### Modify Languages
To customize your application's use of multiple languages at a later date, alter
the `language_default` and `languages` values in `config/public.yml` to change
which languages are used:

```
language_default: es
languages: en|es|cz
```

If adding a new language, copy existing files in `config/locales/` from one
language to new files for the language being added, for example `de.yml` for
German, and translate their contents to the new language.

### Redirects and Rewrites

Orchid contains middleware which allows your app to redirect or rewrite URLs.
This may be useful if you are moving to Orchid from an older website and are
updating the URL structure, or would like to clean up URLs with `.html` and
`.php`. Copy the `config/redirects.example.yml` file to whatever name you would
like (`config/redirects.yml` for our purposes) and enable it in the
`config/public.yml` file. You can add more than one redirect file if you wish:

```yaml
# config/public.yml

default: &default
  app_options:
    redirect_files:
      - config/redirects.yml
      - config/redirects_by_section.yml
```

To get started quickly, follow the examples in
[`config/redirects.example.yml`](../lib/generators/templates/redirects.yml).
The file is formatted as a list of associate arrays so each rule begins with
`-` and following indented lines have the rule's keys and values. Every rule
must have the `method`, `from`, and `to` keys and values.

`method` determines whether the rule is:

- a redirect (and which [HTTP Redirect
Status
Code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_Redirection)
is returned) if the value is `r301`, `r302`, `r303`, `r307`, or `r308`
- a rewrite if the value is `rewrite`

`from` is either a string or regular expression preceded by `!ruby/regexp` that
is matched against the request path and query string to determine when redirects
and rewrites occur.

`to` is a string which defines the destination URL for the redirect or rewrite.
The string may contain numbered backreferences like `$1` which will be replaced
by substrings captured in the `from` value if it is a regular expression.

`options` may be added for further rule conditions. The available `options` keys
are:

- `scheme` - The request scheme must match this string or regular expression,
  e.g. `http` or `https`
- `host` - The host for the request must match this string or regular
  expression, e.g. `cdrh.unl.edu`
- `method` - The request must match this HTTP request method, e.g. `GET`,
  `POST`, `DELETE`, etc
- `not` - The path and query string must _not_ match this string or regular
  expression. This allows excluding some matches for the `from` value.
- `drop_qs` - The query string will be dropped and not added to `to`, the
  destination URL. It will still be matched against the `from` value though.

### Routes

Orchid's routes load after the application's routes by default. This means that
generally you may add routes to the app's `config/routes.rb` file as normal.
Orchid will detect and avoid overriding any named routes which it might
otherwise have set.

You may need to add a route to your application after Orchid's routes have been
drawn. For example, you may wish to add a greedy route which would otherwise
capture many following routes, e.g. `/:id` would capture paths to Orchid routes
for `/about` and `/browse` if drawn first. In this case, you will need to call
Orchid's method to draw its routes before yours.

```ruby
# Draw all of Orchid's routes on-demand, skipping any named routes already drawn
Orchid::Routing.draw
```

If you are adding a named route normally drawn by Orchid, you will need to
prevent Orchid from drawing that route. Orchid's `draw` method accepts a keyword
argument `routes` as an array of specific route names to draw.

```ruby
# Draw specific Orchid routes on-demand, skipping any named routes already drawn
Orchid::Routing.draw(routes: ["home", "item"])
```

#### Scoped Routes
Using Rails's route scoping does not work if wrapped around the Orchid route
drawing. To scope the routes that Orchid draws, an additional keyword parameter
`scope` must be passed to the `draw` method with the same string value that
would be passed to the Rails `scope` method, e.g.

```ruby
# Fails to scope Orchid routes
scope '/orchid-sub-uri' do
  # Other route definitions
  …
  Orchid::Routing.draw
end

# Successfully scopes Orchid routes
scope '/orchid-sub-uri' do
  # Other route definitions
  …
  Orchid::Routing.draw(scope: '/orchid-sub-uri')
end
```

The `Orchid::Routing.draw(scope: …)` call can be outside a Rails `scope` block,
but it will likely be easier to follow to keep it alongside other scoped routes.

If you are adding routes to an app which supports multiple languages, and you
would like the routes to be available to both, you will need to set the scope:

```ruby
scope "(:locale)", locale: locales do
  get '/about/team', to: 'general#about_team', as: 'about_team'
end
```

### Sections
Orchid supports different "sections" of an app utilizing the same Orchid logic
and templates for different purposes. This is primarily for an app to use
separate paths to access different groups of items from the API.

#### Section Config
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

#### Section Routes
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

#### Canonical Item Links
If one uses a section which segregates items but they are still included by the
non-section Orchid search, items may be accessible from multiple paths.
This could lead to display problems if sections apply different styles to items,
and it will be bad for SEO. Using a canonical URL for each item is handled by a
helper for the Items controller which can be overridden in the main app at
`app/helpers/items_helper.rb` as follows:

```ruby
module ItemsHelper
  include Orchid::ItemsHelper

  def search_item_link(item)
    title_display = item["title"].present? ?
      item["title"] : t("search.results.item.no_title", default: "Untitled")
    path = "#"

    # Logic to determine which path helper to use to define path.
    # item["category"], item["subcategory"], and item["identifier"] are likely
    # to be helpful in distinguishing between sections

    link_to title_display, path
  end
end
```

#### Section Links
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

#### Section Templates
Orchid's views and partials are made section-compatible by calling them with
the `render_overridable` method rather than `render`. The exact same parameters
one would use with `render` are available. This replacement method checks for
section-specific template overrides in the main app's `app/views/(secton name)/`
directory before falling back to using the Orchid templates. This allows for
granular overrides of views and partials from the main app as needed without
needing to copy controller methods etc from Orchid.


### (Re)start
After customization, one must (re)start the Rails app.

