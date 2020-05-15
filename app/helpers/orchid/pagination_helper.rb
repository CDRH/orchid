module Orchid::PaginationHelper

  def paginator total_pages, display_range=2
    new_params = copy_params
    total = total_pages.to_i
    if total > 1
      current = valid_page
      pages_prior = (current-display_range..current-1).reject { |x| x <= 1 }
      pages_next = (current+1..current+display_range).reject { |x| x > total }

      render_overridable("items", "paginator",
        current: current,
        opts: new_params,
        pages_next: pages_next,
        pages_prior: pages_prior,
        range: display_range,
        total: total_pages)
    end
  end

  def to_page(page, opts)
    opts.merge({"page" => page.to_s})
  end

  def valid_page
    # matches logic in ApiBridge::Query to determine a valid page request
    !/\A[1-9]\d*\z/.match(params["page"]) ? 1 : params["page"].to_i
  end

end
