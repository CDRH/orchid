require "orchid/engine"
require "orchid/routing"
require "orchid/version"

module Orchid
  module_function

  # Non-configurable constants to be accessible Orchid-wide:

  # List of internal Rails params we want to remove when manipulating parameters
  # for generating search facet/filter links and sending requests to the API.
  # They remain accessible via Rails's params[…] object
  RAILS_INTERNAL_PARAMS = %w[action commit controller locale utf8]

  def facets(section: nil)
    facets = []

    if section.present? && SECTIONS[section] && SECTIONS[section]["facets"].present?
      facets = SECTIONS[section]["facets"]
    else
      facets = FACETS
    end

    if facets.key?(I18n.locale.to_s)
      facets = facets[I18n.locale.to_s]
    elsif facets.key?(APP_OPTS["language_default"])
      facets = facets[APP_OPTS["language_default"]]
    end

    if /\/collection\/\w+$/.match(API_PATH)
      facets.delete("collection")
    end

    facets
  end
end
