module Orchid::SortHelper

  def sorter
    current = ""
    if params["sort"].present? && params["sort"].class == Array
      current = params["sort"][0]
    elsif params["q"].present?
      current = "relevancy|desc"
    else
      current = "title|asc"
    end
    render "sort", current: current, query: params["q"].present?
  end

  def sort type, direction="desc"
    new_params = copy_params
    new_params["sort"] = ["#{type}|#{direction}"]
    new_params.delete("page")
    return new_params
  end

end
