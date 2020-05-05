# Installation

- [RVM](#rvm)
- [All Installs](#all-installs)
- [Usage](#usage)

## Installation
If you have Ruby and Rails installed already, create the Rails app:<br>
`rails new (app name)`

Skip to [All Installs](#all-installs)

### RVM
There are a few additional steps when using RVM
```bash
cd /var/local/www/rails
rvm list

# If Ruby is not installed
rvm install ruby
rvm use ruby(-x.x.x)

# If one skipped the above steps, switch to desired Ruby
rvm use ruby(-x.x.x)
rvm gemset create (app name)
rvm gemset use (app name)

# Install Rails (-N to skip docs, -v to specify version)
gem install rails -N [-v #.#.#]

# Create the Rails app
rails new (app name)

# Set RVM Ruby gemset
echo '(app name)' > (app name)/.ruby-gemset
```

### All Installs
If you are using a local (development) version of Orchid, add the following line
to your Gemfile:

```ruby
gem 'orchid', path: '/absolute/path/to/orchid'
```

Otherwise, grab a version from the CDRH's GitHub. The `tag:` is optional but
recommended, so that your site's functionality does not break unexpectedly when
updating

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
Once Orchid is installed successfully, run the generator to prepare your new
Rails app. Run this with a `--help` to see which app files will be changed
before you begin.

```bash
rails g(enerate) setup
```

Note: If the above command hangs, try running `spring stop`.

The script will ask you for some initial configuration values.

