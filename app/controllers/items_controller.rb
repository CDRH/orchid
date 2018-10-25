class ItemsController < ApplicationController

  def browse
  end

  def browse_facet
    # Reverse facet name from url-formatting
    @browse_facet = params[:facet]
    if @browse_facet.include?(".")
      Facets.facet_info.each_with_index do |(facet_name, facet_info), index|
        if @browse_facet == facet_name.parameterize(separator: ".")
          @browse_facet = facet_name
          break
        end
      end
    end

    # Get selected facet's info
    @browse_facet_info = Facets.facet_info[@browse_facet]
    if @browse_facet_info.blank?
      redirect_to browse_path, notice: t("errors.browse",
        facet: @browse_facet, default: "Cannot browse by key: '#{@browse_facet}'")
      return
    end

    sort_by = params["facet_sort"].present? ?
      params["facet_sort"] : API_OPTS["browse_sort"]

    options = {
      facet: @browse_facet,
      facet_num: 10000,
      facet_sort: sort_by,
      num: 0
    }

    # Get facet results
    @res = $api.query(options).facets

    # Warn when approaching facet result limit
    result_size = @res.length
    if result_size == 10000
      raise {"Facet results list has hit the limit of 10000. Revisit facet
        result handling NOW"}
    elsif result_size >= 9000
      logger.warn {"Facet results list has surpassed 9000 of 10000 limit. Please
        revisit facet result handling SOON"}
    elsif result_size >= 7500
      logger.warn {"Facet results list has surpassed 7500 of 10000 limit. Please
        revisit facet result handling soon"}
    end

    render "browse_facet", locals: { sort_by: sort_by }
  end

  def index
    @ext_js = ["orchid/search"]

    if params["sort"].blank? && params["q"].present?
      params["sort"] = ["relevancy|desc"]
    end

    options = params.permit!.deep_dup
    options, @from, @to = helpers.date_filter(options)

    @res = $api.query(options)
  end

  def show
    @res = $api.get_item_by_id(params["id"]).first
    if @res
      url = @res["uri_html"]
      @html = Net::HTTP.get(URI.parse(url)) if url
    end
  end

end

