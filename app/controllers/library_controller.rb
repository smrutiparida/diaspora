class LibraryController < ApplicationController

  before_filter :authenticate_user!, :only => [:index]
  respond_to :html, :json, :js

  def index
    @documents = Document.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    #@assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
           
    #@assignments = current_user.visible_shareables(Assignment)
    conditions = {
        :contacts => {:user_id => current_user.id, :receiving => true}
      }

    @assignments = Assignment.joins(:posts).joins(:aspect_visibilities).where(
        :aspect_visibilities => {:aspect_id => current_user.aspect_ids})

    #@assignments = Assignment.joins(query)

    respond_to do |format|
      format.html
      format.json {render :json => {'documents' => @documents, 'assignments' => @assignments, 'quizzes' => @quizzes}.to_json}
    end
  end
end