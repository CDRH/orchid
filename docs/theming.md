# Theming and Assets

Orchid has many mechanisms for the host app to customize the appearance of
the site, from minor tweaks to change the colors to overwriting entirely pages.

__Working with Views__

- [Customizing Views](#customizing-views)
- [Favicon](#favicon)
- [Header and Footer](#header-and-footer)

__CSS and JS__

- [Global Styles](#global-styles)
- [Global JavaScript](#global-javascript)
- [Page Classes](#page-classes)
- [Add Assets by Page](#add-assets-by-page)
- [Asset Paths in SCSS](#asset-paths-in-scss)
- [Vendor Assets](#vendor-assets) (incomplete)

## Customizing Views

Orchid's pages are brought to life by views and partials located in `app/views`.

A view is HTML and Ruby code which usually (not always) corresponds to the URL or
controller / action names. Partials are fragments of HTML / Ruby that may be
included by more than one view.

To override an Orchid view or partial, locate the file in an `app/views`
subdirectory and copy it to the same location in your application.

For example, if you are copying the `about` page in
`app/views/general/about.html.erb`, create the `general` directory in your
app's views directory and copy in `about.html.erb`.

Be aware that if you need access to different variables (objects with `@`
at the beginning), you will need to [override a controller](/docs/settings.md#overriding-controllers-and-beyond).

If you are new to Ruby on Rails, you may want to familiarize yourself with the
[Ruby on Rails Action View](https://guides.rubyonrails.org/action_view_overview.html) documentation.

## Favicon

Replace the image at `app/assets/images/favicon.png` to change your app's
favicon.

For wider favicon support, create the necessary derivative images, copy Orchid's
`views/layouts/head/_favicon.html.erb` file to the same location in your app,
and add the additional favicons to `views/layouts/head/_favicon.html.erb`.

## Header and Footer

To change the header and footer, you do not necessarily need to overwrite the
entire application layout file. Instead, consider overriding partials.

`app/views/layouts/body/_footer.html.erb`
`app/views/layouts/body/_navbar.html.erb`
`app/views/layouts/body/_title.html.erb`

## Global Styles

Orchid gives you a number of ways to customize the look and feel of your site.

__Bootstrap Variables__

Orchid currently uses [Bootstrap 3](https://getbootstrap.com/docs/3.3/)
for page layouts and basic appearance.

You may change your app's copy of `app/assets/stylesheets/bootstrap-variables.scss`
to add your own colors and settings.

__Site Specific Styling__

Odds are that you will want to customize your site more than just changing
the colors and some font sizes.

If you look in `app/assets/stylesheets/application.scss`, you will see
the files which Rails is using to create `application.css`, one large file
comprised of all the others. Do not put your styles in this file. Instead,
you can add your styles to `app/assets/stylesheets/orchid.scss` or create a new
stylesheet (`.css` or `.scss`) in `app/assets/stylesheets/global/`.

By default, anything in that `global` directory will be compiled into `application.css`.

## Global JavaScript

One should normally not need to edit `app/assets/application.js`. By default,
this file looks through `app/assets/javascripts/global` for JS files
and includes them sitewide as part of `application.js`.

Add app-wide JavaScript to `app/assets/javascripts/global/(app name).js` or
other scripts in `app/assets/javascripts/global/`.

## Orchid-wide styles and JavaScripts

If you need to make changes that affect all of Orchid (please be careful), you 
need to make changes in the Orchid repo itself. It is best to test them with a 
local copy of Orchid linked to a locally downloaded app in its Gemfile. Note 
that files like applications.scss and application.js are overwritten in 
Orchid-generated apps.

Changes to Orchid styling should be made in the file 
`app/assets/stylesheets/orchid.scss`. Scripts should go in the folder 
`app/assets/javascripts/global`. If they do not appear in your app, make sure 
that they are in the proper folder and are being properly required in 
`app/assets/javascripts/orchid.js`. (The line `//= require_tree ./global` 
includes this folder).

Scripts from external developers go into `vendor/assets/javascripts`. They 
should be required by name `//= require modernizr-custom` (files in the vendor 
folder are automatically in scope to `orchid.js`).

If you get precompilations erros in a test app, when you make a change in 
Orchid, the problem is often the local cache. Clear it with `rake assets:clean` 
and then run `bundle update` again. Otherwise you may need to edit the manifest
files. See [Rails Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html#asset-organization) 
for more information.

## Page Classes

In some cases, you may wish to apply specific styles depending on the page or
section, but do not need to include a whole separate stylesheet only for that 
content.

On the `<html>` element, you have access to a number of built in classes, or
you may choose to pass your own.

- use `@page_classes` variable to assign classes as a string
- `section_[@section]` is available for [sections](#sections)
- `controller_[controller]` (example: "controller_general")
- `action_[action]` (example: "action_show")
- `page_[page]` assigned for pages with the following in the url: about, browse, item, search

You may assign `@page_classes` in the controller action or the view. To add this class from the view, insert this code:

```ruby
<%= @page_classes = "custom_class1 custom_class2" %>
```

You could then style the page with CSS such as:

```css
.custom_class1 body {
  ...
}
```

You may customize the behavior of the `page_[page]` class by overriding the app helper `html_classes_page`.

## Add CSS or JS by Page

When a specific page or section requires CSS / JavaScript which are not relevant
to the rest of the app, you may wish to add a conditional asset.

See [Vendor Assets](#vendor-assets) for more information about 3rd party assets.

First, if you are adding new style or script files which are not globally used,
place them in `app/assets/stylesheets` and `app/assets/javascripts`, respectively.

As with a normal Rails application, you may choose to call these assets with tags
such as `stylesheet_link_tag`, but Orchid provides some helpful methods for
adding assets per page.

- `@ext_css` to specify stylesheet files to include
- `@ext_js` to specify script files to include
- `@inline_css` for passing independent CSS code
- `@inline_js` for passing independent JS code

You may include these in a controller action or the view. Ideally, in order to
avoid accidentally overwriting extra CSS or JS which may already be added
elsewhere, use the `add_assets` helper.

_Examples_

Include leaflet.css and stamen.css in an action:

```ruby
@ext_css = helpers.add_assets(@ext_css, %w(leaflet stamen))
```

Include leaflet.js and search.js in a view:

```ruby
<% @ext_js = add_assets(@ext_js, %w(leaflet search)) %>
```

Apply CSS to a page from a view:

```ruby
<% @inline_css = [".cats .hidden {display: none;}"] %>
```

Apply JS to a page from an action:

```ruby
@inline_js = ["var power_level = 9000;"]
```

To load assets on all pages in a group rendered by a controller, use a [before
filter](https://guides.rubyonrails.org/action_controller_overview.html#filters)
to call the `add_assets` helper:
```ruby
class GroupController < ApplicationController
  before_action :append_assets
  # may also specify actions with `only: [:action2, :action3]`
…
  private

  def append_assets
    @ext_css = helpers.add_assets(@ext_css, "group")
    @ext_js = helpers.add_assets(@ext_js, "group")
  end
end
```

## Asset Paths in SCSS

When writing stylesheets, it is often the case that you will need to include
images or fonts. When doing this in Rails, you need to use the asset pipeline.
When it comes to the `.scss` files, you can reference these assets in the Rails
asset pipeline through use of some helpers.

For example:

`image-url("writings/cather.png")` returns `url(/assets/writings/cather.png-716431504781975841)`

If including a font, you can use `font-url`.

Read more about these helpers in the
[Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html#css-and-sass) documentation.

## Vendor Assets

TODO: This section is incomplete.

If you want to include scripts from an external vendor in your app, put them in 
vendor/assets/javascripts. Scripts here will be automatically linked in the asset pipeline, but they 
should also be required in app/assets/javascripts/application.js:
`//= require leaflet.js`

It may be necessary to clear the cache with `rake assets:clean` to get the app to compile.

See the [Rails Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html#asset-organization)
documentation for more information about including vendor files, which may be
included in the `vendor` directory.

You may need to alter vendor files to include [asset paths](#asset-paths-in-scss)
in those cases where vendor stylesheets are referring to images, etc.

Some systems seem unable to find our assets through the `link_tree`
directives which automatically add them to the asset precompilation list.
For such situations, we still need to add our assets manually in
`config/initializers/assets.rb`. These filenames indicate what the compiled file
will be named rather than the source file, so if one's asset file is
`filename.scss(.erb)` file, it will still be written as `filename.css` here.
The additions to the precompile list may be broken up for organization e.g.:

```ruby
# Group A
Rails.application.config.assets.precompile += %w(
  group_a.css
  group_a.js
)

# Group B
Rails.application.config.assets.precompile += %w(
  group_b.css
  group_b.js
)
```
