module Orchid::SortHelper

  def sorter
    current = ""
    if params["sort"].present? && params["sort"].class == Array
      current = params["sort"][0]
    elsif params["q"].present?
      current = "score|desc"
    else
      current = "title|asc"
    end
    render "sort", current: current, query: params["q"].present?
  end

  def sort type, direction="desc"
    new_params = copy_params

    # If linking to sort by "score" (relevancy), send no sort[] parameter
    if type == "score"
      # sort type "score" results in an API error
      new_params.delete("sort")
    else
      new_params["sort"] = ["#{type}|#{direction}"]
    end

    # If switching sort type or direction, start at first page of results
    new_params.delete("page")
    return new_params
  end

end
