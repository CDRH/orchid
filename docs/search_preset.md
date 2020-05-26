# Search Presets

Some websites may wish to have a simplified list of search results that presents items already winnowed down with facets or a search term to the user without the options of adding or removing facets. For example, the Cody Archive's "Topic" document lists, or an image gallery. These results still need basic functionality such as pagination and sort, but they do not require an entire infrastructure of browsing / faceting.

With this need in mind, Orchid provides a view, `items/search_preset.html.erb` to build item lists of this nature, and allow easy overriding for customization. There are three steps to setting up a search preset.

1. [Route](#route)
2. [Action](#action)
3. [Views](#views)

## Route

First, create a route in your app to a new action.

`config/routes.rb`
```ruby
  get '/memorabilia/souvenirs', to: 'items#souvenirs', as: 'souvenirs'
```

## Action

In the action matching your route, set up a couple variables, create a query to
retrieve an item list, and render the search preset view.

NOTE: If you are working with a `section` (see
[relevant documentation](#sections) for sections), be mindful that you may need
to use a different API connection than the `$api` variable to gain access to
default options specified in that section's configuration.

Here's an example search preset action:

```ruby
def souvenirs
  # optional settings
  @title = "Topics: Wild West Show"
  @content_label = "Souvenirs"
  @preset_class = "category_souvenir"

  # query to return only souvenir documents
  options = params.permit!.deep_dup
  options["f"] = "category|souvenir"
  @res = $api.query(options)

  # render search preset with route information
  @route_path "souvenirs_path"
  render_overridable "items", "search_preset"
end
```
Optional settings:

- @title: not specific to search preset! Used to populate `<title>`.
  Used for `<h1>` if `@content_label` not defined.
- @content_label: used for the `<h1>` tag
- @preset_class: applies `search_preset_(@preset_class)` class to `<div>` surrounding search preset page for custom styling

Required:

- @res: result of a `.query` call to the API or subset API (@section)
- @route_path: string representation of the route used to get to this action

## Views

Good news, you only need to alter one view to get search presets working! If
you are happy with the default appearance, consider yourself done after creating
a file at `items/_search_preset_text.html.erb` and filling in your commentary.

However, if you would like to alter the appearance or behavior, there are
several views / partials made available for the search preset functionality.

- `items/search_preset.html.erb`
- `items/_search_preset_res_items.html.erb`
- `items/_search_preset_text.html.erb`

`search_preset` imitates the default search page but removes references to
facets. Typically, you should not override this view unless making substantial
changes to the layout of the page.

`_search_preset_res_items` renders the traditional `items/_search_res_items`
partial automatically, but if you would like to create a custom layout / display
for the specific items being returned, you may override this partial.

`_search_preset_text` gives you an easily overridable way to add
content to the top of the section you are designing. For example, explanatory
material about an image gallery, or links to other search presets based around
topics. If you do not require any content above the search results, simply add
an empty file at `items/_search_preset_text.html.erb`.
