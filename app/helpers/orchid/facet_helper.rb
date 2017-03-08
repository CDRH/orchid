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

  def datify_name facet_name
    facet_name.gsub(/[\.|]/, "-")
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
    new_params["f"] << "#{type}|#{facet}"
    return new_params
  end

  def facet_selected? type, facet
    if params["f"].present?
      return params["f"].include?("#{type}|#{facet}")
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
    new_params.delete("page")
    new_params["f"].delete("#{type}|#{facet}")
    return new_params
  end

  def should_display? facet, info
    return facet && info["display"] && facet.length > 0
  end

end
