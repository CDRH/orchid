class GeneralController < ApplicationController
  def about
    @title = t "about.title"
    render_overridable("general", "about")
  end

  def index
    render_overridable("general", "index")
  end
end
