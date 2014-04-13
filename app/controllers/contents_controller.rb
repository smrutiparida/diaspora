class ContentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :new,:show]
  respond_to :html, :json, :js

  def index    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    my_aspect_id = current_user.role == "teacher" ? params[:id] : get_my_teacher_aspect_id(params[:id])
    @all_course_modules = Content.where(:aspect_id => my_aspect_id).order(:created_at)
    
    format.json {
      render :json => @all_course_modules.to_json
    }
     
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