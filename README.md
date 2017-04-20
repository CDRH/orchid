# Orchid

Orchid is a generator which can be used to create a new CDRH API template site.  The new site can either connect to the entire API's contents or filter by "type," meaning that the new site can be used for a specific collection.

## Installation

If you have ruby and Rails 5.x installed already, create the Rails app:<br>
`rails new (app name)`

Skip to [All Installs](#all-installs)

### RVM
There are a few additional steps when using RVM
```bash
cd /var/local/www/rails
rvm list

# If ruby 2.4.x is not installed
rvm install ruby-2.4
rvm use ruby-2.4.x
rvm @global do gem install bundler

# If one skipped the above steps, switch to ruby 2.4.x
rvm use ruby-2.4.x
rvm gemset create (app name)
rvm gemset use (app name)

# Install Rails 5.x (--pre for release candidates, --no-ri to skip docs)
gem install rails --pre --no-ri

# Create the rails app
rails new (app name)

# Set RVM ruby version and gemset
echo 'ruby-2.4.x' > (app name)/.ruby-version
echo '(app name)' > (app name)/.ruby-gemset
```

### All Installs
If you are using a local (development) version of orchid, add the following line to your Gemfile:

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
$ bundle install
```

## Usage

Once orchid is installed successfully, run a generator to prepare your new rails app. Run this with a `--help` to see what will be changed before you begin. This will NOT erase or overwrite any configuration files, only example configuration files. 

```bash
$ rails generator setup
```
The script should give you instructions about which steps to take next, but in general you will need to customize the following files:

- config/config.yml
- app/models/facets.rb

## Customization

First open `config/config.yml`.  If you are updating your version of orchid, you may already have an existing config file, so you will want to compare it against the `config/config.example.yml` file to see if there are any changes or additions which have been made.  You should set a path to the API endpoint you would like to use.  This should look like one of the following:

```yaml
api_path: https://api_dev_path.unl.edu
api_path: https://api_dev_path.unl.edu/collection/collection_name
```

Any endpoint is valid as long as the path `/items` could be appended to it in the API to receive a list of items.  In the configuration file you may also set a long project name, and a shortname which will be used for things like the `<title/>` element. You may also change the number of search results which come back by default, and the type of sort which will be used for browsing, and facet defaults, all settings which may be overridden in specific requests.

You may also want to peruse the `app/models/facets.rb` file and alter it for specific fields which you would prefer.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
