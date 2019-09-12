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
#
# You may also need to translate the specific facet results being
# returned by the API and not just the field's label
# For example, the category field might return the values of 4 categories
# If you need to translate these, add the optional boolean "translate":
#
# "es" => {
#   "format" => {
#     "label" => "Categoría",
#     "display": true,
#     "translate": true
#   }
# }
#
# You will then need to add the desired mappings to a locale file. You may add it
# to the general [lang].yml file, or create your own [your_choice].yml.
# Store the values at this path:
#   facet_value.{field_name}.{value_name}
#   fields / values like person.role, "Postal Card" should use underscores
#   => person_role, Postal_Card
#
# es:
#   facet_value:
#     format:
#       photograph: fotografía
#       manuscript: manuscrito


module Facets
end
