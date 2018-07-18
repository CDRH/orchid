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

Most of the navigation, buttons, and general wording throughout orchid has been pulled out into `locales/en.yml`.  Copy that file to match the other language(s) your app will support, for example: `locales/es.yml`.  Translate each entry of the yaml file.  You may toggle between languages in the application and view the language differences.

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
