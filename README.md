# Orchid

Orchid is a multi-lingual Rails engine which handles common functionality across
Rails apps which rely on the CDRH API. It includes a generator for configuring
new Rails apps, which can primarily connect to the endpoint for the entire API's
contents, or connect to an endpoint that only searches a specific collection's
contents. Apps can also configure additional "sections" which use independent
API configurations and search filtering UI, as well as the ability to granularly
overrides templates without the need to copy or create additional Rails
controllers.

## Next steps

Read about installation and configuration instructions in the [Orchid Documentation](docs/README.md).

Orchid maintains a [CHANGELOG](CHANGELOG.md) are provided for upgrading after
new releases

## License
The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
