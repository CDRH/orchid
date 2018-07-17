module Facets

  @facet_info = {
    "en" => {
      "project" => {
        "label" => "Collection",
        "display" => true
      },
      "category" => {
        "label" => "Category",
        "display" => true
      },
      # "date" => {
      #   "label" => "Date",
      #   "display" => true
      # },
      "date.year" => {
        "label" => "Year",
        "display" => true
      },
      "person.name" => {
        "label" => "People",
        "display" => true
      },
      "languages" => {
        "label" => "Language",
        "display" => true
      },
      "subcategory" => {
        "label" => "Subcategory",
        "display" => true
      },
      "creator.name" => {
        "label" => "Creator",
        "display" => true,
      },
      "format" => {
        "label" => "Format",
        "display" => true
      },
      "places" => {
        "label" => "Places",
        "display" => true
      },
    }
    # add fields for other languages with their language code and appropriate labels
    # "es" => {
    #   "category" => {
    #     "label" => "Categoría",
    #     "display" => true
    #   }
    # }
  }

  # Remove project key if API URL uses a specific collection
  if /\/collection\/\w+$/.match(API_PATH)
    @facet_info.delete("project")
  end

  def self.get_facets
    # finds the appropriate facets by language
    if @facet_info.key?(I18n.locale.to_s)
      @facet_info[I18n.locale.to_s]
    elsif @facet_info.key?("en")
      # default to english if it exists
      @facet_info["en"]
    else
      # keep backwards compatibility for now
      @facet_info
    end
  end

  def self.facet_list
    return @facet_info.keys
  end
end
