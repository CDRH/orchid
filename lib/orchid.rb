require "orchid/engine"
require "orchid/routing"
require "orchid/version"

module Orchid
  module_function

  def facets(section: nil)
    facets = []

    if section.present? && SECTIONS[section]["facets"].present?
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
