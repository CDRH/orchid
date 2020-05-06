# Settings Overview and Basics

When you first run the Orchid generator (`rails g setup` in the
[installation](/docs/installation.md#install)), you will be asked to answer a
series of prompts. Never fear if you don't know what to answer, you can change
those values at any time!

- [Locating Settings](#locating-settings)
- [API Connection](#api-connection)
- [Image Server](#image-server)
- [Overriding Controllers and Beyond](#overriding-controllers-and-beyond)

## Locating Settings

Nearly all of the configuration is either in
`config/public.yml`, `config/private.yml`, or `config/locales/[language].yml`.

If you are updating your version of Orchid, you will want to compare your version
of these files against the Orchid config template files to see if any changes
need to be made.

Most of the options in the config files are well documented in the files themselves,
there are a few config settings of which you should be aware.

## API Connection

In `private.yml`, you may set your API path by environment. This path may be
any endpoint in the API to which `/items` can be appended.

The default `api_path` value is `https://cdrhapi.unl.edu/v1`.

```yaml
# config/private.yml

api_path: https://cdrhapi.unl.edu/v1
api_path: https://cdrhapi.unl.edu/v1/collection/collection_name
```

Orchid sets up its API endpoint with some default values, listed under
`api_options`. You may change the following in `config/public.yml`:

- The number of search results which come back by default
- The type of sort which will be used for browsing
- Facet list sizes and sorting
- The earliest and latest dates of the app's documents

All of these settings may be overridden in specific requests later as well.
For more information about these values and options, please consult the
[Apium documentation](https://github.com/CDRH/api).

## Image Server

In the event that the items returned from the API for search results have
images, or if you would like to use images on any item or custom pages, you may
wish to use a IIIF-compatible image server.

Fill in the path to this image server in `private.yml`. If you are using the
`cdrhmedia` server, not include the collection in the path.

```yaml
# config/private.yml

iiif_path: https://cdrhmedia.unl.edu/iiif/2
```

You will also need to include a little more information in `config/public.yml`
about your collection and your preferred thumbnail size. The `collection_name`
is the appropriate subdirectory in the image server file system.
The `thumbnail_size`, when beginning with `!`, will not alter the height / width
ratio of the image.

```yaml
media_server_dir: collection_name
thumbnail_size: "!200,200"
```

For more information about using IIIF images in Orchid, please see [TODO LINK].

## Overriding Controllers and Beyond

In general, most files within Orchid can be overridden by copying that file to
the same location in your Rails app and altering it as desired.

This is not always a recommended workflow, however, as it duplicates a lot of
code and makes it more difficult to update your app. Below are some instructions
for common portions which may need to be overridden.

### Controllers

It is possible to override the behavior of specific actions within controllers.
To add or override a controller action, first create a file in the controllers
directory with a name ending in `_override.rb`. For example,
`app/controllers/general_override.rb`.

Add line at the top that indicates which controller you are
working on:

```ruby
GeneralController.class_eval do

  def action_name
    [code here]
  end

end
```

You may wish to copy the original Orchid action into your controller override
in order to make small alterations to the behavior rather than starting from
scratch.

Be aware that any instance variables in the original Orchid action may still
be expected by the corresponding view.

### Helpers

To override Orchid helper behavior, check out the structure in `app/helpers`.
Do not modify anything in `app/helpers/orchid`. Instead, copy one of the files
in the `helpers` directory to your application. You may now rewrite specific
methods in the `app/helpers/orchid` files or add your own.

### Views and Assets

Please see the [theming documentation](/docs/configuration/theming.md)
for information about overriding views, partials, and assets.

### Routes

Please see the [routing](#TODO) documentation about how to customize the routes.
