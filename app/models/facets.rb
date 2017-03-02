module Facets

  @facet_info = {
    "category" => {
      "label" => "Category",
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
    "project" => {
      "label" => "Collection",
      "display" => true
    },
  }

  def self.facet_info
    return @facet_info
  end

  def self.facet_list
    return @facet_info.keys
  end
end
