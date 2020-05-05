# Links

We will ignore [resourceful
routes](https://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)
for now and focus on the [non-resourceful
routes](https://guides.rubyonrails.org/routing.html#non-resourceful-routes) we
define and name in `config/routes.rb`:

```ruby
# Route with no parameters
get 'about', to: 'general#about', as: :about

# Route requiring a parameter, :id
get 'item/:id', to: 'items#show', as: :item
```

Links are generally written in either what we will call "string form" or "block
form" depending on whether a simple string of text will be clickable or whether
nested HTML such as an image or text that must be marked up with other HTML tags
will be clickable.

In string form, links for the above routes are written:

```html
<li>
  <%= link_to "About", about_path, html_options %>
</li>

<li>
  <%= link_to "Item ABC", item_path("ABC"), html_options %>
</li>
or
<li>
  <%= link_to "Item ABC", item_path(id: "ABC"), html_options %>
</li>
```

The link with the route requiring a parameter may be written two ways. If
parameters are passed to the path helper as an array, they will be set in the
order the parameters appear in the path. Otherwise, they may be named as keys in
a hash. Additional parameters will be appended to the resulting URL as query
string parameters.

It's important to keep parameters meant for the path helper separate from those
intended to be `html_options` by wrapping them in parentheses. `html_options`
are the keyword parameters (e.g. `id: "link_abc", class: "text-center"`)
that add attributes to the `<a>` element. They are automatically passed as a
hash to `link_to` if not explicitly written with brackets around them, which is
rarely necessary. To add `data-name="value"` attributes, pass the attribute
names and values as their own hash, e.g. `data: { name: "value" }`. For other
`html_options`, read the [link_to options
documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to-label-Options).

In block form, the links are written:

```html
<%= link_to about_path, html_options do %>
  <img src="/images/about.png" class="img-responsive" alt="Team photo">
  <span class="text-center">About the Project</span>
<% end %>

<%= link_to item_path("ABC"), html_options do %>
  <img src="/images/item_abc.png" class="img-responsive" alt="ABC photo">
  <span class="text-center">Item ABC</span>
<% end %>
```

See [more examples in the Rails API link_to
documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to-label-Examples).
