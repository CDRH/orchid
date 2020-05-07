# Facets

Facets are API fields used to group items with similar metadata in the "Browse"
pages, e.g. items with the same value in a `category` field. For each language,
which fields are used, their order, their text labels, and their options may
vary.

Each facet may be configured to function as a search filter and to be
translated to another language.

- [Configuration](#configuration)
- [Translations](#translations)

## Configuration

Facet configuration is defined in `config/public.yml` by language:
```yaml
…
  facets:
    [language]:
      [api_field]:
        label: [display_text]
        # Optional features
        flags:
          - search_filter
          - translate
…
```

- `language` - Language code matching the code(s) set in `config/public.yml`
- `api_field` - Field name from the API. Field names may be nested (e.g.
  `creator.name`)
- `display_text` - Text displayed for the facet label for this language

The `flags:` key and its list of contained flag names may be omitted. A flag's
presence in the config file enables changes in facet use and behavior as
follows:

`search_filter` - Enables use of facets as search filters on search pages.

`translate` - Enables translation of the facet values in addition to the facet's
label.

## Translations

Facet translations may be defined inside any YAML file in
`config/locales/` with the following format:

```yaml
[language]:
  facet_value:
    [api_field]:
      [field_value]: [translation]
```

- `language` - Same as above
- `api_field` - Same as above except nested field names must be written with
  underscores replacing periods
    - `field_value` - The text value returned by the API with underscores
    replacing periods, commas, and spaces
    - `translation` - The literal translated text for this particular language

As an example, imagine we have a `source` API field we don't want included in
search filters or translated. We will only show this field in English since it
won't be translated. Also imagine a `film.title` API field (made up here for
demonstation purposes) that we'd like included in search filters as well having
its label text and values translated for Spanish. Our facets configuration would
look like:

```yaml
…
  facets:
    en:
      film.title:
        label: Film Title
        flags:
          - search_filter
      source:
        label: Source
    es:
      film.title:
        label: Título de la Película
        flags:
          - search_filter
          - translate
      # Omitting source field; remember languages may vary facet use and order
…
```

If our title values are `Planes, Tranes, and Automobiles`, `Three Amigos`,
`The Out-of-Towners`, and `Roxanne` we could define our translations in
`config/locales/film_title_es.yml` as:

```yaml
es:
  facet_value:
    film_title:
      Planes__Tranes__and_Automobiles: Aviones, Trenes, y Automóviles
      Three_Amigos: Tres Amigos
      The_Out-of-Towners: Los Fuera de las Ciudades
      Roxanne: Roxanne
```
