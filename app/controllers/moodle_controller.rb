class MoodleController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def assignments
    @assignments = get_assignments(params[:id],params[:aspect_id])    

    respond_with do |format|
      format.json { render :json => @assignments, :status => 200 }	      
    end
  end

end