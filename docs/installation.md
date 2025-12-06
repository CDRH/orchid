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

Make a new directory with the following files: 

- .ruby-gemset (contents: "[whatever you want to name your gemset]")
- .ruby-version (contents: "ruby-3.1.2")

cd into the directory again and install ruby if prompted

Next, install the most recent version of Rails 6.x

```
gem install rails -v 6.1.7
```

check that your rails version is correct

```
rails -v
```

now create a new app in the same directory

```
rails new .
```

Add this line to the app's Gemfile:

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
rails g orchid_setup
```
The setup script will prompt you to enter some values. Don't worry if you don't know all of them, you can change those values later.

Use the [locating settings](/docs/settings.md#locating-settings) docs to find these settings in the app.

## RVM

[RVM](https://rvm.io/), or the Ruby Version Manager, is a handy way to manage multiple Ruby and Rails versions. Install RVM using instructions on the site, then add the following to your new Rails application, making sure to change the values for the Ruby version and app name:

```bash
echo 'ruby-x.x.x' > (app_name)/.ruby-version
echo '(app name)' > (app_name)/.ruby-gemset
cd (app name)
bundle install
```

## Updating modernizr-custom.js
The Modernizr file is used to make sure that all content is visible if JavaScript is not installed, for the sake of accessibility. If you need to update it, the latest version can be downloaded at https://github.com/Modernizr/Modernizr/releases. Navigate in your terminal to the folder you downloaded and run `npm install`. Update the `lib/config-all.json` file with the following line under `"feature-detects"`:
```
  "feature-detects": [
    "dom/classlist"
  ]
```
All other features in this list are unnecessary, and some may prevent the app from working, so make sure they are removed.

Then from the modernizr parent directory, run `./bin/modernizr -c lib/config-all.json -u`. Copy the `modernizr.js` file that appears into your local Orchid repo, put it into `vendor/assets/javascripts`, and rename it as `modernizr-custom.js` (replacing the existing file).
