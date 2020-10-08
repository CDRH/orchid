# Overriding Defaults

In general, most files within Orchid can be overridden by copying that file to
the same location in your Rails app and altering it as desired.

This is not always a recommended workflow, however, as it duplicates a lot of
code and makes it more difficult to update your app. Below are some instructions
for common portions which may need to be overridden.

- [Settings](#settings)
- [Controllers](#controllers)
  - [API Requests](#api-requests)
- [Helpers](#helpers)
- [Views and Assets](#views-and-assets)
- [Routes](#routes)

## Settings

Options such as which filters appear on your search and browse page,
number of results per page, the location of the image server, languages, and
more are part of the application's configuration.

Please refer to the [settings documentation](/docs/settings.md) for more information.

## Controllers

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

Customizing a section controller? Check out the
[sections documentation](/docs/sections.md#controller).

### API Requests

When overriding a controller, you may find it useful to alter the API request.
Please see the documentation for [API Requests](/docs/api_requests.md) for
more information.

## Helpers

To override Orchid helper behavior, check out the structure in `app/helpers`.
Do not modify anything in `app/helpers/orchid`. Instead, copy one of the files
in the `helpers` directory to your application. You may now rewrite specific
methods in the `app/helpers/orchid` files or add your own.

Take a look at some [common helper methods](/docs/helpers.md) that you may be
interested in using or overriding.

## Views and Assets

Please see the [theming documentation](/docs/theming.md)
for information about overriding views, partials, and assets.

## Routes

Please see the [routing documentation](/docs/routes.md#routes) about how to customize the routes.
