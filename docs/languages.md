# Languages

By default, Orchid assumes you are developing an English-only application, but
supports the use of multiple languages. The setup generator called with `rails
g(enerate) setup` will prompt for your default language and list of all
languages.

Most of the navigation, buttons, and general wording throughout Orchid has been
pulled out into strings in `config/locales/en.yml`. Translate each entry of the
YAML file. You may toggle between languages in the application and view the
language differences.

**All translations must start with the language key or Rails will not find the
appropriate text.** An example locales file might look like:

```yaml
# config/locales/en.yml
en:
  title: Example Title
```

The `en` key in the example above is critical to finding the correct string to
display. By default, Orchid starts with an `en.yml` file and any other languages
you specified as files with similar names during setup. However, you may add
more files to help with organization. Just make sure you include the language
key before you begin creating translated strings:

```yaml
# config/locales/explore_en.yml
en:
  explore:
    ...

# config/locales/explore_es.yml
es:
  explore:
    ...
```

Please check the "Facets" section of this README for more information about how
to customize the behavior and labels of the facets by language.

Though you can add HTML to your locales files, often if you want a view with
large amounts of content you may prefer to simply work directly with views
rather than with the locales. You may do this by including the language code in
your filename.

```
app
  |-- views
          |-- explore
                    |-- mountains.html.erb
                    |-- mountains.cz.html.erb
                    |-- mountains.en.html.erb
```

In the above, if the locale were set to Czech with code `cz`, a request for the
mountains view would render `mountains.cz.html.erb`. A request for a language
without a specific view will render the general file `mountains.html.erb`. This
naming convention also applies to partials.

Please refer to the [[Scoped Routes]] documentation for more information about
adding more routes to apps which support multiple languages.

## Modify Languages

To customize your application's use of multiple languages at a later date, alter
the `language_default` and `languages` values in `config/public.yml` to change
which languages are used:

```
language_default: es
languages: en|es|cz
```

If adding a new language, copy existing files in `config/locales/` from one
language to new files for the language being added, for example `de.yml` for
German, and translate their contents to the new language.
