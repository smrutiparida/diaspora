class AssignmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  respond_to :html, :json, :js

  def new
    
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def create
    @assignment = current_user.build_post(:assignment, assignment_params)
    if @assignment.save      
      #@response = {}
      @response = @assignment.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Assignment created successfully."
      respond_to do |format|
        format.js
      end  
    
  #    respond_to do |format|
  #      format.json { render :json => {"success" => true, "data" => @assignment.as_api_response(:backbone)} }        
  #    end
  #  else
  #    flash[:error] = "Assignment creation failed. Please try again!"
  #    respond_to do |format|
  #      format.html do
  #        render :layout => false
  #      end    
  #    end  
    end
  end  

  def assignment_params
    params.require(:assignment).permit(:name, :description,:submission_date,:file_upload,:public, :pending, :aspect_ids)
  end
end