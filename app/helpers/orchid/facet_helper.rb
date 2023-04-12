module Orchid::FacetHelper
  
  def clear_search
    new_params = copy_params
    new_params.delete("q")
    new_params.delete("f")
    new_params.delete("page")
  end

  def create_label key, default="No Label"
    key.present? ? key : default
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
    return facet.present? && info["flags"] \
      && info["flags"].include?("search_filter")
  end

  # the particular value of, for example, the "format" field may need
  # to be displayed in another language based on the app settings
  # so if the "translate" flag is present for a field in facet configuration,
  # then check for translations via locale files
  # yml values need to be the exact field name at
  #   facet_value.{field_name}.{value_name}
  #   fields / values like person.role, "Postal Card" are stored
  # in locales yml as person_role, Postal_Card
  def value_label field, value
    # if @page_facets are not present, for example if a search_preset
    # view or a custom action are using the metadata method,
    # do not error but just skip possible translations
    if @page_facets.present?
      info = @page_facets[field]
      if value.present? && info && info["flags"] \
        && info["flags"].include?("translate")
        field_name = field.gsub(".", "_")
        # if this is a list of values, we need to return a list as well
        subs = /[\., ]/
        if value.class == Array
          value.compact.map do |v|
            v = v.gsub(subs, "_")
            t "facet_value.#{field_name}.#{v}", default: v
          end
        else
          value_name = value.gsub(subs, "_")
          t "facet_value.#{field_name}.#{value_name}", default: value
        end
      else
        parse_md_brackets(value)
      end
    else
      parse_md_brackets(value)
    end
  end

end
