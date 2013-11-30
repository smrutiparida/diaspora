class AssignmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create]

  def new
    
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def create
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
    
  end
end