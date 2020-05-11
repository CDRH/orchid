# Routes and Redirects

- [Redirects and Rewrites](#redirects-and-rewrites)
- [Routes](#routes)
  - [Scoped Routes](#scoped-routes)
- [Canonical Item Paths](#canonical-item-paths)

## Redirects and Rewrites

Orchid contains middleware which allows your app to redirect or rewrite URLs.
This may be useful if you are moving to Orchid from an older website and are
updating the URL structure, or would like to clean up URLs with `.html` and
`.php`. Copy the `config/redirects.example.yml` file to whatever name you would
like (`config/redirects.yml` for our purposes) and enable it in the
`config/public.yml` file. You may add more than one redirect file if you wish:

```yaml
# config/public.yml

default: &default
  app_options:
    redirect_files:
      - config/redirects.yml
      - config/redirects_by_section.yml
```

To get started quickly, follow the examples in
[`config/redirects.example.yml`](../lib/generators/templates/redirects.yml).
The file is formatted as a list of associative arrays so each rule begins with
`-` and following indented lines have the rule's keys and values. Every rule
must have the `method`, `from`, and `to` keys and values.

`method` determines whether the rule is:

- a redirect (and which [HTTP Redirect
Status
Code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_Redirection)
is returned) if the value is `r301`, `r302`, `r303`, `r307`, or `r308`
- a rewrite if the value is `rewrite`

`from` is either a string or regular expression preceded by `!ruby/regexp` that
is matched against the request path and query string to determine when redirects
and rewrites occur.

`to` is a string which defines the destination URL for the redirect or rewrite.
The string may contain numbered backreferences like `$1` which will be replaced
by substrings captured in the `from` value if it is a regular expression.

`options` may be added for further rule conditions. The available `options` keys
are:

- `scheme` - The request scheme must match this string or regular expression,
  e.g. `http` or `https`
- `host` - The host for the request must match this string or regular
  expression, e.g. `cdrh.unl.edu`
- `method` - The request must match this HTTP request method, e.g. `GET`,
  `POST`, `DELETE`, etc
- `not` - The path and query string must _not_ match this string or regular
  expression. This allows excluding some matches for the `from` value.
- `drop_qs` - The query string will be dropped and not added to `to`, the
  destination URL. It will still be matched against the `from` value though.

## Routes

(Are you looking for [section routes](/docs/sections.md#routes)?)

Orchid's routes load after the application's routes by default. This means that
generally you may add routes to the app's `config/routes.rb` file as normal.
Orchid will detect and avoid overriding any named routes which it might
otherwise have set.

You may need to add a route to your application after Orchid's routes have been
drawn. For example, you may wish to add a greedy route which would otherwise
capture many following routes, e.g. `/:id` would capture paths to Orchid routes
for `/about` and `/browse` if drawn first. In this case, you will need to call
Orchid's method to draw its routes before yours.

```ruby
# Draw all of Orchid's routes on-demand, skipping any named routes already drawn
Orchid::Routing.draw
```

If you are adding a named route normally drawn by Orchid, you will need to
prevent Orchid from drawing that route. Orchid's `draw` method accepts a keyword
argument `routes` as an array of specific route names to draw.

```ruby
# Draw specific Orchid routes on-demand, skipping any named routes already drawn
Orchid::Routing.draw(routes: ["home", "item"])
```

### Scoped Routes

Using Rails's route scoping does not work if wrapped around the Orchid route
drawing. To scope the routes that Orchid draws, an additional keyword parameter
`scope` must be passed to the `draw` method with the same string value that
would be passed to the Rails `scope` method, e.g.

```ruby
# Fails to scope Orchid routes
scope '/orchid-sub-uri' do
  # Other route definitions
  …
  Orchid::Routing.draw
end

# Successfully scopes Orchid routes
scope '/orchid-sub-uri' do
  # Other route definitions
  …
  Orchid::Routing.draw(scope: '/orchid-sub-uri')
end
```

The `Orchid::Routing.draw(scope: …)` call can be outside a Rails `scope` block,
but it will likely be easier to follow to keep it alongside other scoped routes.

If you are adding routes to an app which supports multiple languages, and you
would like the routes to be available to both, you will need to set the scope:

```ruby
scope "(:locale)", locale: locales do
  get '/about/team', to: 'general#about_team', as: 'about_team'
end
```

## Canonical Item Paths

The app display the same item at a variety of paths, for example, if using [sections](/docs/sections.md) or using custom URLs to group items according to criteria such as category / subcategory.

This isn't good for a number of reasons, such as SEO. Preferably, each item will only show up at one canonical path. How does Orchid know which URL this is?

First off, it's recommended to lock down your item routes to recognize if they've
been asked to display an item incorrectly. In the below example,
the `life/:id` route is only prepared to display four documents. the
`writings/books/:id` route is looking for ids such as `0001` or `nf060`.

```ruby
…
  get 'life/:id', to: 'life#show', as: :life_item,
    constraints: { id: /chronology|shortbio|longbio|woodress/ }
  get 'writings/books/:id', to: 'items#show', as: :writings_book_item,
      constraints: { id: /(\d{4}|nf006(?:_\d{2})?|nf060|nf061)/ }
…
```

Typically, we can write links in views and partials which use the named path, such as

```ruby
life_item_path(id: item_id)
writings_books_item_path(id: item_id)
```

But when creating links dynamically, such as in search results, we need to
set up some rules to help the app decide which path is appropriate.

This is facilitated by overriding the
helper method used to render them in `app/helpers/items_helper.rb`:

```ruby
module ItemsHelper
  include Orchid::ItemsHelper

  def search_item_link(item)
    category = item["category"].downcase
    item_id = item["identifier"][/^cat\.(.+)$/, 1]
    path = "#"
    title_display = item["title"].present? ?
      item["title"] : t("search.results.item.no_title", default: "Untitled")

    if category == "life"
      item_id = item_id[/^life\.(.+)$/, 1]
      path = life_item_path(id: item_id)
    elsif category == "writing"
      path = writings_book_item_path(id: item_id)
    end

    link_to title_display, path
  end
end
```

The above example uses `category` to determine the appropriate route, but your
logic may be quite different depending on how you will be selecting routes for
pages.
