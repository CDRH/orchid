module Orchid::DisplayHelper
  # res: API result hash
  # label: field display label ("Category")
  # api_field: the corresponding API field
  # link: whether or not text or a link to search results
  #       for the given filter will be displayed, defaults
  #       to displaying a link
  # separator: the characters used to distinguish between items
  #       in a list, defaults to " | "
  def metadata(res, label, api_field, link: true, separator: " | ", show_label: true)
    data = metadata_get_field_values(res, api_field)

    if data.present?
      html = show_label ? metadata_label(label, length: data.length) : ""

      # iterate through the field values
      dataArray = data.map do |item|
        if link
          metadata_create_field_link(api_field, item)
        else
          # in this case there isn't a normalized version because
          # the data comes from a document result, so just use item
          facet_label(type: api_field, normalized: item, label: item)
        end
      end
      html << dataArray
                .map { |i| "<span>#{i}</span>" }
                .join(separator)

      sanitize html
    end
  end

  # put together a search path with an f[] parameter
  #   example: ?f[]=category|Writings
  def metadata_create_field_link(api_field, item)
    search_params = { "f" => ["#{api_field}|#{item}"] }
    item_label = facet_label(type: api_field, normalized: item, label: item)
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
  #   length intended to be used for pluralization,
  #   or could be used by overriding applications if desired
  def metadata_label(label, length: nil)
    # TODO add pluralization that uses locale
    "<strong>#{label}:</strong> "
  end

end
