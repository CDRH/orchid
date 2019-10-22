module Orchid::DisplayHelper
  # res: API result hash
  # label: field display label ("Category")
  # api_field: the corresponding API field
  # link: whether or not text or a link to search results
  #       for the given filter will be displayed, defaults
  #       to displaying a link
  # separator: the characters used to distinguish between items
  #       in a list, defaults to " | "
  def metadata(res, label, api_field, link: true, separator: " | ")
    data = metadata_get_field_values(res, api_field)

    if data.present?
      html = metadata_label(label, data.length)

      # iterate through the field values
      dataArray = data.map do |item|
        link ? metadata_create_field_link(api_field, item) : item
      end
      html += dataArray
                .map { |i| "<span>#{i}</span>" }
                .join(separator)

      sanitize html
    end
  end

  # put together a search path with an f[] parameter
  #   example: ?f[]=category|Writings
  def metadata_create_field_link(api_field, item)
    search_params = { "f" => ["#{api_field}|#{item}"] }
    item_label = value_label(api_field, item)
    link_to item_label, prefix_path("search_path", search_params),
      rel: "nofollow"
  end

  # regardless of whether the results are a simple array or an array
  # of hashes (a nested field), return a list of the values
  def metadata_get_field_values(res, api_field)
    # only nested fields use "." in their name
    if api_field.include?(".")
      nested = api_field.split(".")
      # fields are only nested one level deep
      res[nested.first].map { |doc| doc[nested[1]] }
    else
      Array(res[api_field])
    end
  end

  # metadata label has been separated to allow apps to override included HTML
  #   length is not currently used but is predicted to be used, or could
  #   be used by overriding applications if desired
  def metadata_label(label, length)
    # TODO potentially add pluralization by locale
    "<strong>#{label}:</strong> "
  end

end
