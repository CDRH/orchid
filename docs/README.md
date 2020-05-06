# Orchid

Orchid is a multi-lingual Rails engine which handles common functionality across
Rails apps which rely on the CDRH API. It includes a generator for configuring
new Rails apps, which can primarily connect to the endpoint for the entire API's
contents, or connect to an endpoint that only searches a specific collection's
contents. Apps can also configure additional "sections" which use independent
API configurations and search filtering UI, as well as the ability to granularly
overrides templates without the need to copy or create additional Rails
controllers.

## General Documentation

- [Installation](/docs/installation.md)
- [Configuration](/docs/configuration.md)
  - [Settings Overview and Basics](/docs/configuration/settings.md)
  - [Theming and Assets](/docs/configuration/theming.md)
  - [Routes and Redirects](/docs/configuration/routes.md)
  - [Customizing Facets and Browse](/docs/configuration/facets.md)
  - [Languages](/docs/configuration/languages.md)
  - [Sections](/docs/configuration/sections.md)

## License
The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
