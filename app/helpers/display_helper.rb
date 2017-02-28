module DisplayHelper

  # TODO refactor this?
  # It will need to handle nested fields if nothing else
  
  def metadata(res, label, search_ele, link_bool=true)
    data = res[search_ele]
    if data
      html = "<li><strong>#{label}:</strong> "
      data = data.class == Array ? data : [data]
      dataArray = data.map do |item|
        if link_bool
          search_params = { f: ["#{search_ele}|#{item}"] }
          link_to item, search_path(search_params)
        else
          item
        end
      end
      html += dataArray.join(" | ")
      return html.html_safe
    end
  end

end
