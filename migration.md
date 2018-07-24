# Migration

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
