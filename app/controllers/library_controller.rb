class LibraryController < ApplicationController

  before_filter :authenticate_user!, :only => [:index]
  respond_to :html, :json, :js

  def index
    @documents = Document.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    #@assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    #@quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
           
    
    #below logic valid for students. For teachers the logic will be different.
    if params[:a_id]
      all_my_posts = Post.joins(:aspect_visibilities).where(
          :aspect_visibilities => {:aspect_id => params[:a_id]})
    else
      all_my_posts = Post.joins(:aspect_visibilities).where(
          :aspect_visibilities => {:aspect_id => current_user.aspect_ids})  
    end  
    all_my_post_guid = all_my_posts.map{|a| a.guid}
    
    @assignments = Assignment.where(:status_message_guid => all_my_post_guid)
    @quizzes = Quiz.where(:status_message_guid => all_my_post_guid)
    @documents += Document.where(:status_message_guid => all_my_post_guid)

    respond_to do |format|
      format.html
      format.json {render :json => {'documents' => @documents, 'assignments' => @assignments, 'quizzes' => @quizzes}.to_json}
    end
  end
end