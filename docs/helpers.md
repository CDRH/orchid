# Helpful Helpers

Orchid comes with a variety of helpers, methods which are typically used in
views but which can also be used by controllers. In some cases, it is strongly
recommended that you use these helpers to assist with problems that we've already
figured out.

- [add_assets](#add_assets)
- [iiif](#iiif)
- [prefix_path](#prefix_path)
- [render_overridable](#render_overridable)

## add_assets

Use this when you are adding page-specific assets such as CSS and JS to an
action or view.

Example:

```ruby
<%= @ext_css = add_assets(@ext_css, ["some_css"] ) %>
```

See [theming documentation](/docs/theming.md#add-assets-by-page)
for more information.

## iiif

`iiif` if used to generate URLs for images which can be served out of a IIIF
compatible image server. In order to use this helper, you will need to have
filled out your [image server configuration](/docs/settings.md#image-server).

This method accepts a number of IIIF options, such as region, size, rotation,
quality, and format. It returns a URL for the requested resource.

Example:

```ruby
<%= iiif("shan_p.330.jpg", region: "pct:30,30,70,70", size: "!1000,1000") %>
```

## prefix_path

`prefix_path` helps figure out the appropriate path based on the current section
of the site.

Example:

```ruby
# use this
link_to "label", prefix_path("search_path", { "f" => ["subcategory|Manuscript"] })

# as opposed to
link_to "label", search_path( { "f" => [ "subcategory|Manuscript" ]})
```

Read more in the [sections docs](/docs/sections.md#links).

## render_overridable

Similar to `prefix_path`, `render_overridable` seeks to make sure that the
appropriate view or partial is rendered when using sections.

Example:

```ruby
render_overridable("items", "browse")
```

You can call it the same way you would typically call `render`.

Read more in the [sections docs](/docs/sections.md#templates).

## route_path and @route_path

Allows for overriding the default behavior of views / partials such as sort
and pagination. The default behavior is to use "search_path".

`route_path` is important for search preset functionality. Read more about
[search presets](/docs/search_preset.md).

Example:

```ruby
# controller/action

  def image_gallery
    @route_path = "image_gallery_path"
    render "items/search_preset"
  end
```
