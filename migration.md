# Migration Instructions

## Unreleased

## 3.0.1 to 3.0.2

References to `site_section` should be changed to `html_classes`.

## 3.0.0 to 3.0.1

Fixes bug with date search and incorrect locale path

## 2.1.0 to 3.0.0

`metadata` method in DisplayHelper altered so final argument is now
a keyword argument, `link` which defaults to true. Previously, this
was a non-keyword argument.

Provides basic support for IIIF image URLs in views with the helper `iiif(partial_image_path, size: "!150,150")`

__config/private.yml__

`iiif_path` must be added, see example in orchid's `private.yml` template

__config/public.yml__

- `app_options.media_server_dir` is the name of the project's directory
  following the IIIF server path
- `app_options.thumbnail_size` is the width and height of the image. Use "!" to
  preserve the ratio. Ex: "!200,200"
- `app_options.languages` must now delimit all languages used in the app, rather
  than only non-default languages

__config/initializers/config.rb__

Add `IIIF_PATH = PRIVATE["iiif_path"]` to this file to make `IIIF_PATH` accessible to application

__app/assets/config/manifest.js__

Copy `app/assets/config/manifest.js` to same path in existing apps

__Gemfile__

Ensure that all Gemfile updates from the generator have been added:

- `gem 'sass-rails' …` replaced with `gem 'sassc-rails', '~> 2.1'`
- `gem 'chromedriver-helper'` replaced with `gem 'webdrivers'`
- `gem 'bootstrap-sass'` has version constraint `'~> 3.4.1'`

## 2.0.0 to 2.1.0

This "minor" version changes configuration and addresses display bugs

__config/public.yml__

`title`, `subtitle`, and `shortname` have been moved to the locale files for language support. This is technically a breaking change for existing sites using 2.0.0 which relied on the default behavior for a single language to pull from the config instead of `locales/en.yml`, but as that is currently only one site, we are considering it a minor change.

__assets__

Recompile assets after updating to 2.1.0


## 1.1.1 to 2.0.0

This major version introduces multiple language support.

__config/public.yml__

This bump adds the ability to control the following settings, but they are optional.  Default behavior is English language only.

```
# defaults to "en" (english) if no default language set
# language_default: en
# defaults to "en" if nothing passed in, pipe delineated values
# languages: en|es
```

__config/locales/en.yml__

Copy orchid's `config/locales/en.yml` file into the same location in your app and customize it as desired. If the app has overridden default views, partials, and helpers, review them and determine if the files should be changed to match the orchid language support for localization.

```
<h1><%= t "about.title", default: "About" %></h1>
```

__app/models/facets.rb__

Orchid will continue to work with the 1.1.1 `facets.rb` setup, but if you would like multilanguage support and to prepare for potential deprecation in the future, it is recommended to remove everything from `facets.rb` and include only the facet definitions themselves.  Please note that they are being defined with `Facets.facet_info = ...` instead of `@facet_info = ...`.

```
module Facets
  extend Orchid::Facets

  Facets.facet_info = {
    "en" => {
      "project" => {
        "label" => "Collection",
        "display" => true
      },
      (more facet definitions here)
    }
  }
end

```
