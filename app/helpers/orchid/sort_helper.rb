module Orchid::SortHelper

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

  def sort type, direction="desc"
    new_params = copy_params
    new_params["sort"] = ["#{type}|#{direction}"]
    new_params.delete("page")
    return new_params
  end

end
