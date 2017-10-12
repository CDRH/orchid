module Orchid::SortHelper

  def sort(typedir)
    # typedir expected to be field|direction
    new_params = copy_params
    new_params["sort"] = [typedir]
    new_params.delete("page")
    return new_params
  end

  def sorter
    sort_by = ""

    if params["sort"].blank?
      if params["q"].present?
        sort_by = "relevancy|desc"
      else
        sort_by = API_OPTS["sort"].present? ? API_OPTS["sort"] : "title|asc"
      end
    else
      sort_by = params["sort"]
    end

    sort_by = sort_by.first if sort_by.class == Array

    render "sort", sort_by: sort_by
  end

  def sort_fields
    # relevancy|desc included by default with q parameter
    # include blank key to indicate groupings
    {
      "date|asc" => "Date (earliest first)",
      "date|desc" => "Date (latest first)",
      "" => "",
      "title|asc" => "Title (A-Z)",
      "title|desc" => "Title (Z-A)",
    }
  end

  def sort_selected_label(sort_by)
    if sort_by == "relevancy|desc"
      "Relevancy"
    elsif sort_fields.keys.include?(sort_by)
      sort_fields[sort_by]
    else
      params["sort"].size == 1 ? params["sort"].first : params["sort"]
    end
  end

end
