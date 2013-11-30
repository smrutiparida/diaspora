class AssignmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]
  respond_to :html, :json

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
      respond_to do |format|
        format.json { render :json => {"success" => true, "data" => @assignment.as_api_response(:backbone)} }        
      end
    else
      flash[:error] = "Assignment creation failed. Please try again!"
      respond_to do |format|
        format.html do
          render :layout => false
        end    
      end  
    end
  end  
end