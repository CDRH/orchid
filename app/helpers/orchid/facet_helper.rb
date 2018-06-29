module Orchid::FacetHelper
  
  def clear_search
    new_params = copy_params
    new_params.delete("q")
    new_params.delete("f")
    new_params.delete("page")
  end

  def create_label key, default="No Label"
    return key ? key : default
  end

  # type = "novel"
  # facet = "emma"
  def facet_link type, facet, remove_others=false
    new_params = copy_params
    # if "f" not present, create new array
    new_params["f"] = [] if new_params["f"].blank?
    # remove page to start new results over
    # note: does not alter sort, query selections
    new_params.delete("page")
    # if remove_others specified, then will not add same type of
    # facet
    if remove_others
      new_params["f"].each do |f|
        new_params["f"].delete(f) if f.include?(type)
      end
    end
    # verify that this exact facet has not already been added
    facet_label = "#{type}|#{facet}"
    if !new_params["f"].include?(facet_label)
      new_params["f"] << facet_label
    end
    return new_params
  end

  # can return either true when
  # f[] = ["category|(anything)"]
  # or you can specify that you would like to match exactly
  # f[] = ["category|Writings"], etc
  # will depend on if second parameter is sent
  def facet_selected? type, facet=""
    if params["f"].present?
      if facet && facet.length > 0
        return params["f"].include?("#{type}|#{facet}")
      else
        return params["f"].any? { |f| f.include?(type) }
      end
    else
      return false
    end
  end

  def pull_out_fparams
    if params["f"].present?
      return params["f"].map do |f|
        f.split("|").first
      end
    else
      return []
    end
  end

  def remove_facet type, facet
    new_params = copy_params
    new_params["f"].delete("#{type}|#{facet}")
    # Remove page to return to first page of reorganized results
    new_params.delete("page")
    return new_params
  end

  def should_display? facet, info
    return facet && info["display"] && facet.length > 0
  end

end
