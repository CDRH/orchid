# Assets

- [Javascript Inclusions and Asset
  Declarations](#javascript-inclusions-and-asset-declarations)
- [Stylesheet Imports](#stylesheet-imports)
- [Conditional Assets](#conditional-assets)

## Assets
Orchid is compatibile with both Sprockets 3.x and Sprockets 4.x. Adding
additional global or conditional assets behaves the same for both versions.

The asset pipeline has been configured to facilitate adding assets without
the need to update the asset precompilation list or copy/merge files when
changes are made to Orchid's assets.

Declaring assets for auto and precompilation with `link_tree` directives
bypasses the need to add to the list of paths in the config variable
`Rails.application.config.assets.precompile` in `config/initializers/assets.rb`.

### JavaScript Inclusions and Asset Declarations
The generated app's `application.js` first includes the jQuery and Bootstrap
gems' assets.

Next, it includes `orchid.js` from the Orchid engine's assets, which is
accessible because the `require` directive accesses files via the default Rails
asset path locations, which include the Orchid engine's
`app/assets/javascripts/` directory.

The `orchid.js` file then recursively declares all files in the Orchid engine's
`app/assets/javascripts/orchid/`, `app/assets/images/orchid/`, and
`app/assets/stylesheets/orchid/` directories for auto and precompilation with
`link_tree` directives. All three are declared in `orchid.js` because Sprockets
directives do not work in .scss files and one must declare image assets in
the same place as JavaScript and/or stylesheet assets. Orchid's assets are
declared here because `link_tree` only uses relative paths and a relative path
from within the generated app, while possible, would not be portable.

The scripting below the `link_tree` directives will run on every page loaded via
apps with the Orchid engine.

Then returning to the generated app's `application.js` file, we declare all of
the app's assets for auto and precompilation. Again we declare them via the
`link_tree` directive with relative paths.

Lastly, we include scripts from the generated app's
`app/assets/javascripts/global/` directory to run on all pages in the app.
We use the `require_directory` directive here to only include scripts at the top
of `app/assets/javascripts/global/`. We don't want conditional or modular `.js`
files in framework subdirectories included on all pages.

### Stylesheet Imports
The generated app's `application.scss` first imports a generated app-specific
Bootstrap variable file and the Bootstrap gem's assets.

Next, it imports `orchid.scss` from the Orchid engine's assets, which is
accessible because the `@import` directive accesses files via the default Rails
asset path locations, which include the Orchid engine's
`app/assets/stylesheets/` directory.

Lastly, we import stylesheets from the generated app's
`app/assets/stylesheets/global/` directory to be applied to all pages in the
app.

### Conditional Assets
Our views may load assets conditionally rather than on every page in the app.
Conditional asset files must be added to
`(app|vendor)/assets/(javascripts|stylesheets)/`, and not to the `global/`
subdirectories found within. One may create subdirectories for organization if
desired, but the subdirectory must be included with the asset filename when
added. Note that asset filenames do not need the file extension as it will be
handled by Rails:

```ruby
# for app/assets/javascripts/section/page.js
@ext_js = helpers.add_assets(@ext_js, "section/page")
```

We've written an application helper `add_assets` intended to make the code
easier to read and less error prone. Asset filenames may be written as multiple
strings:
```ruby
@ext_css = helpers.add_assets(@ext_css, "sheet1", "sheet2")
```

or using [percent string
syntax](https://ruby-doc.org/core/doc/syntax/literals_rdoc.html#label-Percent+Strings)
for an array of strings:
```ruby
@ext_css = helpers.add_assets(@ext_css, %w(sheet1 sheet2))
```

Conditional asset loading may be handled in either the controller using the
syntax above or in the view template without the `helpers.` syntax:
```ruby
<% @ext_css = add_assets(@ext_css, %w(sheet1 sheet2)) %>
```

To load assets on all pages in a group rendered by a controller, use a [before
filter](https://guides.rubyonrails.org/action_controller_overview.html#filters)
to call the `add_assets` helper:
```ruby
class GroupController < ApplicationController
  before_action :append_assets
…
  private

  def append_assets
    @ext_css = helpers.add_assets(@ext_css, "group")
    @ext_js = helpers.add_assets(@ext_js, "group")
  end
end
```

The before filter may be configured to only apply to a list of specific actions
within the controller too:
```ruby
  before_action :append_assets, only: [:action1, :action3]
```

If a group's pages are rendered by more than one controller, one may add a
check in the application controller or action used by multiple pages to add
assets if the request path matches:
```ruby
if request.path[/^\/group\//]
  @ext_css = helpers.add_assets(@ext_css, "group")
  @ext_js = helpers.add_assets(@ext_js, "group")
end
```

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
