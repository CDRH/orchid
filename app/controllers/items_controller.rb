class ItemsController < ApplicationController
  before_action :set_items_api
  before_action :set_page_facets, only: [:browse, :browse_facet, :index, :show]

  def browse
    @title = t "browse.title"

    render_overridable("items", "browse")
  end

  def browse_facet
    # Reverse facet name from url-formatting
    @browse_facet = params[:facet]
    @filter = params[:f]
    if @browse_facet.include?(".")
      @page_facets.each_with_index do |(facet_name, facet_info), index|
        if @browse_facet == facet_name.parameterize(separator: ".")
          if @page_facets[facet_name]["alternate"]
            @browse_facet = [facet_name, @page_facets[facet_name]["alternate"]]
          else
            @browse_facet = facet_name
          end
          break
        end
      end
    end
    # Get selected facet's info
    @browse_facet_info = @page_facets[@browse_facet] || @page_facets[@browse_facet[0]]
    if @browse_facet_info.blank?
      redirect_to browse_path, notice: t("errors.browse",
        facet: @browse_facet, default: "Cannot browse by key: '#{@browse_facet}'")
      return
    end

    sort_by = params["facet_sort"].present? ?
      params["facet_sort"] : API_OPTS["browse_sort"]
    options = {
      facet: @browse_facet.to_s,
      facet_num: 10000,
      facet_sort: sort_by,
      num: 0
    }
    if @filter
      options["f"]=@filter
    end
    # Get facet results
    @res = @items_api.query(options)
    check_response
    @res = @res.facets

    # Warn when approaching facet result limit
    result_size = @res ? @res.length : 0
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

    @title = "#{t "browse.browse_type"} #{@browse_facet_info["label"]}"
    check_response
    @route_path = "browse_facet_path"
    render_overridable("items", "browse_facet", locals: { sort_by: sort_by, route_path: @route_path })
  end

  def index
    @ext_js = ["orchid/search"]

    if params["sort"].blank? && params["q"].present?
      params["sort"] = ["relevancy|desc"]
    end
    options = params.permit!.deep_dup
    options, @from, @to = helpers.date_filter(options)
    @title = t "search.title"
    @res = @items_api.query(options)
    check_response
    render_overridable("items", "index")
  end

  def show
    item_retrieve(params["id"])
    check_response
  end

  private

  # display a flash message if the API response has an error
  def check_response
<<<<<<< HEAD
    if @res.blank? || @res.error
=======
    if !@res || @res.error
>>>>>>> 38450dd (catches api error and adds flash warning to affected pages)
      flash[:error] = t "errors.api"
    end
  end

  def item_retrieve(id)
    @res = @items_api.get_item_by_id(id)
    check_response
    @res = @res.first
    if @res
      url = @res["uri_html"]
      @html = Net::HTTP.get(URI.parse(url)) if url
      @title = item_title

      render_overridable("items", "show")
    else
      @title = t "item.no_item", id: id,
        default: "No item with identifier #{id} found!"
      render_overridable("items", "show_not_found", status: 404)
    end
  end

  # separated from show action to allow overriding only the
  # title display for individual items instead of the entire action
  def item_title
    if @res["title"].present?
      @res["title"].length > 20 ? "#{@res["title"][0,20]}..." : @res["title"]
    else
      "Item #{@res["identifier"]}"
    end
  end

  def set_items_api
    if @section.present? && $api_sections.present? &&
      $api_sections.key?(@section)

      @items_api = $api_sections[@section]
    else
      @items_api = $api
    end
  end

  def set_page_facets
    @page_facets = @section.present? ?
      Orchid::facets(section: @section) : Orchid::facets
  end

end

