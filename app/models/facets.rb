module Facets

  @facet_info = {
    "cdrh-category" => {
      "label" => "Category",
      "display" => true
    },
    "cdrh-subcategory" => {
      "label" => "Sub Category",
      "display" => true
    }
  }

  def self.facet_info
    return @facet_info
  end

  def self.facet_list
    return @facet_info.keys
  end
end
