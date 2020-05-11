# Languages

By default, Orchid assumes you are developing an English-only application, but
supports the use of multiple languages. The setup generator called with `rails
g(enerate) setup` will prompt for your default language and list of all
languages you would like your application to use.

- [Alter Existing Translations](#alter-existing-translations)
- [Add More Translations](#add-more-translations)
- [Languages Other than English and Spanish](#languages-other-than-english-and-spanish)
- [Facets](#translating-facets)
- [Views](#views)
- [Modify Languages After Creation](#modify-languages-after-creation)

More information about internationalization in Rails is available in the
[Rails i18n guide](https://guides.rubyonrails.org/i18n.html).

## Alter Existing Translations

Check out `/config/locales`. You should see yml files named by language
codes. You may edit these files to change strings as desired for things such as
your site title, home page text, etc.

## Add More Translations

When adding new views, you will need to make sure that all textual content is
translatable to all the languages of your site.

For shorter text or simple paragraphs, you may define your terms in a locale
file and instruct Rails to look for it.

You may add your new translations to the bottom of an existing file or create a
new file in the `locales` directory.

**All new files must start with the language key or Rails will not find the
appropriate text.** An example locales file might look like:

```yaml
# config/locales/explore_en.yml
en:
  explore:
    title: Exploring the World
```

You could then call this string from a view with the `t` helper:

```ruby
<%= t "explore.title", default: "Exploring the World" %>
```

The default keyword is optional, and provides a fallback if for some reason
the app can't find a translation of the string.

## Languages Other than English and Spanish

Most of the navigation, buttons, and general wording throughout Orchid has been
pulled out into strings in `config/locales/en.yml` and `config/locales/es.yml`.
Translate each entry of the YAML file into your needed language(s).
You may toggle between languages in the application and view the
language differences as you go.

```yaml
# config/locales/af.yml
af:
  title: Site titel
```

Remember to start your file with the language code, such as the`af` key in the example above!

## Facets

The CDRH API currently only supports a single language, which makes it difficult
for Orchid applications which need to represent the content in multiple languages.

You can use a yml file to translate facets returned from the API. Read more in the [facets documentation](/docs/facets.md#translations).

Additionally, you can specify different fields and behavior for facets based on
language. You can learn about it in the
[facets configuration docs](/docs/facets.md#configuration).

## Views

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

Please refer to the [Scoped Routes](/docs/routes.md#scoped-routes)
documentation for more information about adding more routes to apps which
support multiple languages.

## Modify Languages After Creation

To customize your application's use of multiple languages at a later date, alter
the `language_default` and `languages` values in `config/public.yml` to change
which languages are used:

```
language_default: es
languages: en|es|cz
```

Then copy existing files in `config/locales/` from an existing
language to new files for the language being added, for example `de.yml` for
German, and translate their contents to the new language.
