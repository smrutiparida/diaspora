class AssignmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index]
  respond_to :html, :json, :js

  def new
    @assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)   
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end
  
  def index
    @assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
  end
  
  def create
    @assignment = current_user.build_post(:assignment, assignment_params)
    if @assignment.save      
      #@response = {}
      @response = @assignment.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Assignment created successfully."
    else
      @response[:success] = true
      response[:message] = "Assignment creation failed. Please try again!"  
    end  
   
    respond_to do |format|
      format.js
  end  

  def assignment_params
    params.require(:assignment).permit(:name, :description,:submission_date,:file_upload,:public, :pending, :aspect_ids)
  end
end