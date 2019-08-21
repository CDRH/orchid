module Orchid::ItemsHelper
  # Include related helpers not auto-included by matching controller name
  include DateHelper
  include DisplayHelper
  include FacetHelper
  include PaginationHelper
  include SortHelper

  def search_item_link(item)
    title_display = item["title"].present? ?
      item["title"] : t("search.results.item.no_title", default: "Untitled")

    link_to title_display, prefix_path("item_path", id: item["identifier"])
  end
end
