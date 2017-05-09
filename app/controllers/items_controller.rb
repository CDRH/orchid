class ItemsController < ApplicationController

  def browse
  end

  def browse_facet
    # Reverse facet name from url-formatting
    @browse_facet = params[:facet]
    if @browse_facet.include?("-")
      Facets.facet_info.each_with_index do |(facet_name, facet_info), index|
        if @browse_facet == facet_name.parameterize
          @browse_facet = facet_name
          break
        end
      end
    end

    # Get selected facet's info
    @browse_facet_info = Facets.facet_info[@browse_facet]
    if @browse_facet_info.blank?
      redirect_to browse_path, notice: "Cannot browse by key: '#{@browse_facet}'"
      return
    end

    # Get facet results
    @res = $api.query({"facet" => @browse_facet, "facet_num" => 500, "facet_sort" => "term|asc" }).facets
  end

  def index
    @ext_js = ["search"]
    @res = $api.query(params)
  end

  def show
    @res = $api.get_item_by_id(params["id"]).first
  end

end
