# ####################
# Facets Configuration
# ####################
#
# Individual facets must contain the following features:
#   "[api_field]" => {
#     "label" => "[label_to_display]",
#     "display" => [boolean]
#   }
#
# The portions in brackets must be customized
#   api_field: this should match a field in the API, and may be nested (creator.name)
#   label_to_display: how the field appears in the website
#   display boolean: if true, this facet appears on the search and browse pages
#                    if false, it only appears on the browse page
#
# ##################
# Multiple Languages
# ##################
#
# if the facets will need to pull different fields or display different labels
# for multiple languages, you may organize them by language keys and customize behavior
#
# Facets.facet_info = {
#   "en" => {
#     "category" => { "label" => "Category", "display" : true }
#   },
#   "es" => {
#     "category" => { "label" => "Categoría", "display": false }
#   }
# }

module Facets
  extend Orchid::Facets

  Facets.facet_info = {
    "en" => {
      "collection" => {
        "label" => "Collection",
        "display" => true
      },
      "category" => {
        "label" => "Category",
        "display" => true
      },
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
    },
    # add fields for other languages with their language code
    # "es" => {
    #   "category" => {
    #     "label" => "Categoría",
    #     "display" => true
    #   }
    # }
  }

end
