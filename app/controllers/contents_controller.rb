class ContentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :new]
  respond_to :html, :json, :js

  def index    
    respond_to do |format|
      format.html
    end
  end
  
  def new   
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def create
    @new_module = current_user.build_post(:content, content_params)  

  	if @new_module.save
      respond_to do |format|
        format.js
      end
    end
  end    
	
  def content_params
    params.require(:content).permit(:name, :a_id)
  end
end