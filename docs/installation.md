# Installation

- [Dependencies](#dependencies)
- [Install](#install)
- [RVM](#rvm)

## Dependencies

- [Ruby](https://www.ruby-lang.org/en/) (recommend using [RVM](#rvm) to install)
- A new [Ruby on Rails](https://rubyonrails.org/) app
- [CDRH Apium](https://github.com/CDRH/api) (or an implementation of the same API spec)
  - You may be interested in the [cdrhapi endpoint](https://cdrhapi.unl.edu/v1/), which is used by default
- IIIF image server endpoint (optional, used to pull display images in search results if they exist)

## Install

If you already have Ruby / Rails installed, create a new Rails app (`rails new (your app)`) and add this line to the app's Gemfile:

```ruby
# Specify desired tag (release), branch, or ref
gem 'orchid', git: 'https://github.com/CDRH/orchid', tag: 'v3.x.x'
```

If you are working on development, you will need to use a local path instead:

```ruby
gem 'orchid', path: '/path/to/orchid/app'
```

Then, install the gem and run the Orchid generator:

```bash
bundle install
spring stop
rails g setup
```
The setup script will prompt you to enter some values. Don't worry if you don't know all of them, you can change those values later.

Use the [locating settings](/docs/configuration/settings.md#locating-settings) docs to find these settings in the app.

## RVM

[RVM](https://rvm.io/), or the Ruby Version Manager, is a handy way to manage multiple Ruby and Rails versions. Install RVM using instructions on the site, then add the following to your new Rails application, making sure to change the values for the Ruby version and app name:

```bash
echo 'ruby-x.x.x' > (app_name)/.ruby-version
echo '(app name)' > (app_name)/.ruby-gemset
cd (app name)
bundle install
```
