class CoursesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :parse]
  respond_to :html, :json, :js

  def index    
    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end
end