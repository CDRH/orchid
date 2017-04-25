class ItemsController < ApplicationController

  def browse
    @res = $api.query({"facet_num" => 500, "facet_sort" => "term|asc" }).facets
  end

  def index
    @ext_js = ["search"]
    @res = $api.query(params)
  end

  def show
    @res = $api.get_item_by_id(params["id"]).first
  end

end
