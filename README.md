# Orchid

Orchid is a generator which can be used to create a new CDRH API template site.  The new site can either connect to the entire API's contents or filter by "type," meaning that the new site can be used for a specific collection.

## Contents

- [Installation](#installation)
  - [RVM](#rvm)
  - [All Installs](#all-installs)
- [Usage](#usage)
- [Configuration](#configuration)
  - [API](#api)
  - [Facets](#facets)
  - [Favicon](#favicon)
  - [Footer Logo](#footer-logo)
  - [Gitignore](#gitignore)
  - [Routes](#routes)
  - [Scripts](#scripts)
  - [Stylesheets / Bootstrap](#stylesheets--bootstrap)
  - [(Re)start](#restart)
- [Assets](#assets)
  - [Javascript Inclusions and Asset Declarations](#javascript-inclusions-and-asset-declarations)
  - [Stylesheet Imports](#stylesheet-imports)
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
gem 'orchid', git: 'https://github.com/CDRH/orchid', tag: '0.0.2'
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

The script will ask you for some initial configuration values.


## Configuration
Most app configuration is located in `config/config.yml`.  If you are updating your version of Orchid, you may already have an existing config file, so you will want to compare it against the `config/config.example.yml` file to see if there are any changes or additions which have been made.

### API
The API path may be any endpoint in the API to which `/items` can be appended to receive a list of items.  This should look like one of the following:

```yaml
api_path: https://api_dev_path.unl.edu
api_path: https://api_dev_path.unl.edu/collection/collection_name
```

There are more variables related to API search results not set when running the generator script. You may change:
- The number of search results which come back by default
- The type of sort which will be used for browsing
- Facet list sizes and sorting
- The earliest and latest dates of the app's documents

All of these settings may be overridden in specific requests later as well.

### Facets
You may also want to peruse the `app/models/facets.rb` file and alter it for specific fields which you would prefer.

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

### Routes

Orchid's routes load after the application's routes.  This means that generally you may add routes to the app's `config/routes.rb` file as normal.  Orchid will detect and avoid overriding any named routes which it might otherwise have set.

Occasionally you may wish to add a route to your application after Orchid's default routes have been drawn.  For example, you may wish to add or alter a route which would otherwise capture many following routes (`/:id` would capture paths like `/about` and `/browse` if drawn first).  In this case, you will need to instruct Orchid to draw its routes before your paths.

```
# in application's config/routes.rb

Orchid::Routing.draw
```

If you will be overriding a named route set by Orchid as a default, you will need to tell Orchid not to draw that route.  You may pass a list of route names.

```
Orchid::Routing.draw(reserved_names: ["item", "home"])
```

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


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
