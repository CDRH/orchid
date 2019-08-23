module Orchid::Facets

  # alter app/models/facets.rb to customize your application's facets
  @facet_info = {}

  # retrieves list of facets by appropriate language
  def facet_info
    filter_facets
  end

  # sets the list of facets with or without the entire API's collections
  def facet_info=(val)
    # Remove collection key if API URL uses a specific collection
    if /\/collection\/\w+$/.match(API_PATH)
      val.delete("collection")
    end
    @facet_info = val
  end

  def facet_list
    facets = filter_facets
    return facets.keys
  end

  def filter_facets
    # finds the appropriate facets by language
    if @facet_info.key?(I18n.locale.to_s)
      @facet_info[I18n.locale.to_s]
    elsif @facet_info.key?(APP_OPTS["language_default"])
      @facet_info[APP_OPTS["language_default"]]
    else
      @facet_info
    end
  end

  def section_facets(section)
    if SECTIONS[section]["facets"].key?(I18n.locale.to_s)
      facets = SECTIONS[section]["facets"][I18n.locale.to_s]
    elsif SECTIONS[section]["facets"].key?(APP_OPTS["language_default"])
      facets = SECTIONS[section]["facets"][APP_OPTS["language_default"]]
    else
      facets = SECTIONS[section]["facets"]
    end

    if /\/collection\/\w+$/.match(API_PATH)
      facets.delete("collection")
    end

    facets
  end

  def section_list(section)
    section_facets(section).keys
  end

end
