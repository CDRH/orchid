module Orchid::FacetHelper
  
  def clear_search
    new_params = copy_params
    new_params.delete("q")
    new_params.delete("f")
    new_params.delete("page")
  end

  def create_label(key, default="No Label")
    key.present? ? key : default
  end

  # type: type of facet (category, format, etc)
  # normalized: the normalized value ("willa cather", "Yellowstone Kelly")
  #     used for URL creation and translation matching
  # label: non normalized value ("Willa Cather", '"Yellowstone Kelly"')
  def facet_label(type: nil, normalized: nil, label: nil)
    # determine if translation needed
    info = @page_facets[type]
    if info && info["flags"] && info["flags"].include?("translate")
      # do not need "label" since that will be found in the locale info
      facet_label_translation(type: type, normalized: normalized)
    else
      # if there is no label specified, use the normalized version
      sanitize(label) || normalized
    end
  end

  def facet_label_translation(type: nil, normalized: nil)
    field_name = type.gsub(".", "_")
    # if this is a list of values, we need to return a list as well
    subs = /[\., ]/
    if normalized.class == Array
      normalized.compact.map do |v|
        v = v.gsub(subs, "_")
        t "facet_value.#{field_name}.#{v}", default: v
      end
    else
      value_name = normalized.gsub(subs, "_")
      t "facet_value.#{field_name}.#{value_name}", default: normalized
    end
  end

  # type = "novel"
  # facet = "emma"
  def facet_link(type, facet, remove_others=false, original_facet=nil)
    type = original_facet if original_facet
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
    new_params
  end

  # can return either true when
  # f[] = ["category|(anything)"]
  # or you can specify that you would like to match exactly
  # f[] = ["category|Writings"], etc
  # will depend on if second parameter is sent
  def facet_selected?(type, facet="")
    if params["f"].present?
      if facet && facet.length > 0
        params["f"].include?("#{type}|#{facet}")
      else
        params["f"].any? { |f| f.include?(type) }
      end
    else
      false
    end
  end

  # format_facet_response takes facet info from Apium v1.0 and
  # Apium v1.1+ and returns an array agnostic of the Apium version
    # v1.0 -> non_normalized_key: num ("Willa Cather": 10)
    # v1.1 -> normalized_key: { num: "", source: "" }
  # returns [key_for_urls, label_to_display, num]
  def format_facet_response(key, value)
    if value && value.class == Hash
      # this is a 1.1+ response from Apium
      [ key, value["source"], value["num"] ]
    else
      # this is a 1.0 response from Apium
      msg = "Apium v1.0 responses not supported in Orchid 4.0"
      ActiveSupport::Deprecation.warn(msg)
      [ key, key, value ]
    end
  end

  def pull_out_fparams
    if params["f"].present?
      params["f"].map do |f|
        f.split("|").first
      end
    else
      []
    end
  end

  def remove_facet(type, facet)
    new_params = copy_params
    new_params["f"].delete("#{type}|#{facet}")
    # Remove page to return to first page of reorganized results
    new_params.delete("page")
    new_params
  end

  def should_display?(facet, info)
    facet.present? && info["flags"] \
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
    msg = "DEPRECATION WARNING: value_label will be removed by Orchid 4.0"
    Rails.logger.warn(msg)
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
        value
      end
    else
      value
    end
  end

end
