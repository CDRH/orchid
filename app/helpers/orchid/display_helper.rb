module Orchid::DisplayHelper
  # res: API result hash
  # label: field display label ("Category")
  # search_ele: the corresponding API field
  # link: whether or not text or a link to search results
  #       for the given filter will be displayed, defaults
  #       to displaying a link
  def metadata(res, label, search_ele, link: true)
    data = res[search_ele]
    if data.present?
      html = "<li><strong>#{label}:</strong> "
      dataArray = Array(data).map do |item|
        if link
          search_params = { "f" => ["#{search_ele}|#{item}"] }
          item_label = value_label(search_ele, item)
          link_to item_label, prefix_path("search_path", search_params),
            rel: "nofollow"
        else
          item
        end
      end
      html += dataArray.join(" | ")
      return html.html_safe
    end
  end

end
