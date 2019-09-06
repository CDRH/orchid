# Orchid

Orchid is a generator which can be used to create a new CDRH API template site.  The new site can either connect to the entire API's contents or filter by "type," meaning that the new site can be used for a specific collection.

## Contents

- [Installation](#installation)
  - [RVM](#rvm)
  - [All Installs](#all-installs)
- [Usage](#usage)
- [Configuration](#configuration)
  - [API](#api)
  - [Canonical Search Item Paths](#canonical-search-item-paths)
  - [Controllers and Actions](#controllers-and-actions)
  - [Facets](#facets)
  - [Favicon](#favicon)
  - [Footer Logo](#footer-logo)
  - [Gitignore](#gitignore)
  - [Languages](#languages)
  - [Redirects and Rewrites](#redirects-and-rewrites)
  - [Routes](#routes)
    - [Scoped Routes](#scoped-routes)
  - [Sections](#sections)
    - [Section Config](#section-config)
    - [Section Routes](#section-routes)
    - [Section Links](#section-links)
    - [Section-compatible Orchid Code](#section-compatible-orchid-code)
  - [Scripts](#scripts)
  - [Stylesheets / Bootstrap](#stylesheets--bootstrap)
  - [(Re)start](#restart)
- [Assets](#assets)
  - [Javascript Inclusions and Asset Declarations](#javascript-inclusions-and-asset-declarations)
  - [Stylesheet Imports](#stylesheet-imports)
  - [Conditional Assets](#conditional-assets)
- [Links](#links)
- [License](#license)

## Installation
If you have ruby and Rails installed already, create the Rails app:<br>
`rails new (app name)`

Skip to [All Installs](#all-installs)

### RVM
There are a few additional steps when using RVM
```bash
cd /var/local/www/rails
rvm list

# If ruby is not installed
rvm install ruby
rvm use ruby(-x.x.x)
rvm @global do gem install bundler

# If one skipped the above steps, switch to desired ruby
rvm use ruby(-x.x.x)
rvm gemset create (app name)
rvm gemset use (app name)

# Install Rails (--no-ri to skip docs)
gem install rails --no-ri

# Create the rails app
rails new (app name)

# Set RVM ruby version and gemset
echo 'ruby(-x.x.x)' > (app name)/.ruby-version
echo '(app name)' > (app name)/.ruby-gemset
```

### All Installs
If you are using a local (development) version of Orchid, add the following line to your Gemfile:

```ruby
gem 'orchid', path: '/absolute/path/to/orchid'
```

Otherwise, grab a version from the CDRH's github.  The `tag:` is optional but recommended, so that your site's functionality does not break unexpectedly when updating

```ruby
gem 'orchid', git: 'https://github.com/CDRH/orchid'

# Specify a tag (release), branch, or ref
gem 'orchid', git: 'https://github.com/CDRH/orchid', tag: '2.0.0'
```

And then execute:
```bash
bundle install
```


## Usage
Once Orchid is installed successfully, run the generator to prepare your new rails app. Run this with a `--help` to see which app files will be changed before you begin.

```bash
rails g(enerate) setup
```

Note: If the above command hangs, try running `spring stop`.

The script will ask you for some initial configuration values.


## Configuration
Most app configuration is located in `config/public.yml` and `config/private.yml`.  If you are updating your version of Orchid, you may already have existing config files, so you will want to compare them against the orchid config template files to see if any changes need to be made.

### API
The API path may be any endpoint in the API to which `/items` can be appended to receive a list of items.  The path is set in `config/private.yml`.  This should look like one of the following:

```yaml
api_path: https://api_dev_path.unl.edu
api_path: https://api_dev_path.unl.edu/collection/collection_name
```

There are more variables related to API search results not set when running the generator script. You may change the following in `config/public.yml`:
- The number of search results which come back by default
- The type of sort which will be used for browsing
- Facet list sizes and sorting
- The earliest and latest dates of the app's documents

All of these settings may be overridden in specific requests later as well.  Please refer to https://github.com/CDRH/api for more information about the options.

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
It is possible to override the behavior of specific actions within controllers.  To add or override a controller action, first create a file in the controllers directory with a name ending in `_override.rb`.  For example, `app/controllers/general_override.rb`.

Then, you will need a line at the top that indicates which controller you are working on.

```
GeneralController.class_eval do

  def action_name
    [code here]
  end

end
```

You can also override an entire controller by simply placing a file with the controller's name in the controllers directory.  For example, `app/controllers/general_controller.rb` would take the place of the Orchid version of this file.  *This approach is not recommended.*

### Facets
You may also want to peruse the `app/models/facets.rb` file and alter it for specific fields which you would prefer.  If your app supports multiple languages, you will need to make sure that the facets are organized by language, for example:

```
{
  "en": {
    ...facets...
  },
  "es": {
    ...facets...
  }
}
```


### Favicon
Replace the image at `app/assets/images/favicon.png` to change your app's
favicon.

For wider favicon support, create the necessary derivative images and uncomment
the other markup in `views/layouts/head/_favicon.html.erb`.

### Footer Logo
Replace the placeholder image at `app/assets/images/footer_logo.png` to change
your app's footer logo.

### Gitignore
Add any other files which should not be version controlled to `.gitignore`.

### Languages
By default, Orchid assumes you are developing an English-only application. However, if you wish to add multiple languages or change the default language, first change `config/public.yml`:

```
language_default: es
languages: en|es
```

Most of the navigation, buttons, and general wording throughout orchid has been pulled out into `locales/en.yml`.  Copy that file to match the other language(s) your app will support, for example: `locales/es.yml`.  Translate each entry of the yaml file.  You may toggle between languages in the application and view the language differences. **This file must exist for every language your app config specifies and must have the language key at the top of the file.**  Otherwise rails will not be able to find the appropriate language text for your application.

Please check the "Facets" section of this README for more information about how to customize the behavior and labels of the facets by language.

If you need to override a view to accommodate large amounts of content in multiple languages, please first create a directory to hold the specific language variation partials within your views.  The name of the controller and partial in the example should be modified for your application and purpose:

```
# app/views/[controller]

excavation_sites
        |-- sites_cz.html.erb
        |-- sites_en.html.erb
        |-- sites_es.html.erb
_normal_partial.html.erb
show.html.erb
traditions
        |-- traditions_cz.html.erb
        |-- traditions_en.html.erb
        |-- traditions_es.html.erb
```

To call the appropriate partial depending on language, include this in a view:

```
<%= render localized_partial("sites", "[controller]/excavation_sites") %>
```

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

### Sections
Orchid supports different "sections" of an app utilizing the same Orchid logic
and templates for different purposes. This is primarily for an app to use
separate paths to access different groups of items from the API.

#### Section Config
Each section uses its own API and facet configuration. Section configuration is
defined in the main app in a YAML file with the same name as the section inside
`config/sections/`. For a section named `letters`, the file would be
`config/sections/letters.yml`. The file must contain the keys `api_options:` and
`facets:`.

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

#### Section Links
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

#### Section-compatible Orchid Code
To make Orchid routes compatible with sections, the `section` parameter must be
set at the beginning of the `proc` for the route definition. This `section`
parameter will be the section name set in the main app routes file. Then if a
section is present it needs an underscore appended. The route name must now be
written with the section name prepended. Lastly, the section name needs to
be available to the controllers and actions called by the route. This is done by
setting the name as a default parameter named `section`. The resulting
section-compatible Orchid route looks like this:

```ruby
{ name: 'item', definition: proc { |section|
  section += "_" if section.present?
  get 'item/:id', to: 'items#show', as: "#{section}item",
    constraints: { id: with_period }, defaults: { section: section }
}},
```

Orchid's views and partials are made section-compatible by calling them with
the `render_overridable` method rather than `render`. The exact same parameters
one would use with `render` are available. This replacement method checks for
section-specific template overrides in the main app's `app/views/(secton name)/`
directory before falling back to using the Orchid templates. This allows for
granular overrides of views and partials from the main app as needed without
needing to copy controller methods etc from Orchid.

### Scripts
One should normally not need to edit `app/assets/application.js`.

Add app-wide JavaScript to `app/assets/javascripts/global/(app name).js` or
other scripts in `app/assets/javascripts/global/`.

Conditional scripting files included via `@ext_js` instance variable, e.g.:<br>
`@ext_js = %w(leaflet search)`

Conditional inline scripting included via `@inline_js` instance variable, e.g.:<br>
`@inline_js = ["var power_level = 9000;"]`

### Stylesheets / Bootstrap
One should normally not need to edit `app/assets/application.scss`

Customize Bootstrap in `app/assets/stylseheets/bootstrap-variables.scss`

Add app-wide styling to `app/assets/stylesheets/global/(app name).scss`
or other stylesheets in `app/assets/stylesheets/global/`

Conditional stylesheets are included via `@ext_css` instance variable, e.g.:<br>
`@ext_css = %w(leaflet stamen)`

Conditional inline styling are included via `@inline_css` instance variable, e.g.:<br>
`@inline_css = [".cats .hidden {display: none;}"]`

### (Re)start
After customization, one must (re)start the Rails app.


## Assets
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

To load assets on all pages rendered by a controller, use a [before
filter](https://guides.rubyonrails.org/action_controller_overview.html#filters)
to call the `add_assets` helper:
```ruby
class SectionController < ApplicationController
  before_action :append_assets
…
  private

  def append_assets
    @ext_css = helpers.add_assets(@ext_css, "section")
    @ext_js = helpers.add_assets(@ext_js, "section")
  end
end
```

The before filter may be configured to only apply to a list of specific actions
within the controller too:
```ruby
  before_action :append_assets, only: [:action1, :action3]
```

If a section's pages are rendered by more than one controller, one may add a
check in the application controller or action used by multiple pages to add
assets if the request path matches:
```ruby
if request.path[/^\/section\//]
  @ext_css = helpers.add_assets(@ext_css, "section")
  @ext_js = helpers.add_assets(@ext_js, "section")
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
# Section A
Rails.application.config.assets.precompile += %w(
  section_a.css
  section_a.js
)

# Section B
Rails.application.config.assets.precompile += %w(
  section_b.css
  section_b.js
)
```

## Links
We will ignore [resourceful
routes](https://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)
for now and focus on the [non-resourceful
routes](https://guides.rubyonrails.org/routing.html#non-resourceful-routes) we
define and name in `config/routes.rb`:

```ruby
# Route with no parameters
get 'about', to: 'general#about', as: :about

# Route requiring a parameter, :id
get 'item/:id', to: 'items#show', as: :item
```

Links are generally written in either what we will call "string form" or "block
form" depending on whether a simple string of text will be clickable or whether
nested HTML such as an image or text that must be marked up with other HTML tags
will be clickable.

In string form, links for the above routes are written:

```html
<li>
  <%= link_to "About", about_path, html_options %>
</li>

<li>
  <%= link_to "Item ABC", item_path("ABC"), html_options %>
</li>
or
<li>
  <%= link_to "Item ABC", item_path(id: "ABC"), html_options %>
</li>
```

The link with the route requiring a parameter may be written two ways. If
parameters are passed to the path helper as an array, they will be set in the
order the parameters appear in the path. Otherwise, they may be named as keys in
a hash. Additional parameters will be appended to the resulting URL as query
string parameters.

It's important to keep parameters meant for the path helper separate from those
intended to be `html_options` by wrapping them in parentheses. `html_options`
are the keyword parameters (e.g. `id: "link_abc", class: "text-center"`)
that add attributes to the `<a>` element. They are automatically passed as a
hash to `link_to` if not explicitly written with brackets around them, which is
rarely necessary. To add `data-name="value"` attributes, pass the attribute
names and values as their own hash, e.g. `data: { name: "value" }`. For other
`html_options`, read the [link_to options
documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to-label-Options).

In block form, the links are written:

```html
<%= link_to about_path, html_options do %>
  <img src="/images/about.png" class="img-responsive" alt="Team photo">
  <span class="text-center">About the Project</span>
<% end %>

<%= link_to item_path("ABC"), html_options do %>
  <img src="/images/item_abc.png" class="img-responsive" alt="ABC photo">
  <span class="text-center">Item ABC</span>
<% end %>
```

See [more examples in the Rails API link_to
documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to-label-Examples).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
