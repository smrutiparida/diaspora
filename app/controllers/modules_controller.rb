class ModulesController < ApplicationController

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
  	@new_module = Module.new
    @new_module.name = params[:module][:name]
    @new_module.aspect_id = params[:a_id]
    

  	if @new_module.save
      respond_to do |format|
        format.js
      end
    end
  end    
	
  def module_params
    params.require(:module).permit(:name, :a_id)
  end
end