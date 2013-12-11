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

    query = Post.joins(:contacts).where(conditions).joins(:contacts => :aspect_memberships).where(
        :aspect_memberships => {:aspect_id => current_user.aspect_ids})

    @assignments = Assignment.joins(:query).where('query.status_message_guid' => :status_message_guid)

    respond_to do |format|
      format.html
      format.json {render :json => {'documents' => @documents, 'assignments' => @assignments, 'quizzes' => @quizzes}.to_json}
    end
  end
end