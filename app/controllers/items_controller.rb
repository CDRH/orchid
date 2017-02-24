class ItemsController < ApplicationController

  def index
    @res = $api.query(params)
  end

end
