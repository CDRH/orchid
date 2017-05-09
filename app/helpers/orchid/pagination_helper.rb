module Orchid::PaginationHelper

  def paginator total_pages, display_range=3
    new_params = copy_params
    total = total_pages.to_i
    if total > 1
      current = new_params["page"] ? new_params["page"].to_i : 1
      pages_prior = (current-display_range..current-1).reject { |x| x <= 1 }
      pages_next = (current+1..current+display_range).reject { |x| x >= total }

      render "paginator",
        current: current,
        opts: new_params,
        pages_next: pages_next,
        pages_prior: pages_prior,
        range: display_range,
        total: total_pages
    end
  end

  def to_page page, opts
    return opts.merge({"page" => page.to_s})
  end

end
