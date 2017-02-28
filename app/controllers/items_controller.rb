class ItemsController < ApplicationController

  def index
    @res = $api.query(params)
  end

  def show
    @res = $api.get_item_by_id(params["id"]).first
  end

end
