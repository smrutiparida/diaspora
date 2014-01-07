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
      format.html
    end
  end

  def create
  	@m = current_user.build_post(:module, module_params)
  	if @m.save
      respond_to do |format|
        format.js
      end
    end
  end    
	
  def module_params
    params.require(:module).permit(:name, :a_id)
  end
end