# API Requests

When you are [overridding default controllers](/docs/overrides.md) or adding
new [sections](/docs/sections.md) and [search presets](/docs/search_preset.md),
you may find yourself needing to create custom API requests.

- [Accessing the Connection](#accessing-the-connection)
- [Querying](#querying)
  - [The Response](#the-response)
  - [Querying by ID](#querying-by-id)

## Accessing the Connection

When you first start an Orchid app, it connects to the API endpoint specified
in your `config/private.yml` file with default settings from `config/public.yml`.

That Query object is stored with a global variable:

```ruby
$api
```

Typically, you will not need to work directly with `$api`. In the
ItemsController, you are provided with an instance variable:

```ruby
@items_api
```

`@items_api` will return either `$api` or a section appropriate connection, if
you are working with sections.

The section API connection information is stored in `$api_sections`, although
you should rarely need to use it directly.

## Querying

Orchid uses the CDRH API's syntax for requests. You should familiarize yourself
with the [API documentation](https://github.com/CDRH/api) before writing custom
requests.

When you initialize your application, Orchid sets up default query parameters
using your config file settings.

This means that you do not need to specify things such as the number of items
per page, starting sort, facets, and any default filters for new queries, since
they are already built in as a convenience.

However, you may override those defaults as desired when creating a new query.

A typical query will look something like this:

```ruby
@items_api.query({ hash of options })
```

For example, the following would bring back results of Willa Cather's writing with the text "birthday":

```ruby

options = {
  "f" => [ "category|Writings", "creator.name|Cather, Willa" ],
  "q" => "birthday"
}
@items_api.query(options)
```

### The Response

`.query` returns a Response object which has the following methods:

- count : the number of items found
- facets : a hash with facets + facet counts you requested
- items : an array of the documents you requested
- first : the first item
- pages: the page count needed to display all the items

### Querying by ID

Although you could send a `.query({ identifier: "some.id" })` request and
select the first item, orchid provides a helpful method to get a single item:

```ruby
@items_api.get_item_by_id("some.id").first
```
