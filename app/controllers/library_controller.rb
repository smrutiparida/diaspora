class LibraryController < ApplicationController

  before_filter :authenticate_user!, :only => [:index]
  respond_to :html, :json, :js

  def index
    #role = Roles.where(:person_id => current_user.person.id, :name => 'teacher').first
    #@teacher = role.nil? ? false : true
    @assignment_active = (params[:tab] == "assignment") ? 1 : 0
    
    @documents = Document.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    
    #below logic valid for students. For teachers the logic will be different.
    if @teacher
      @assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
      @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    else
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
    end

    respond_to do |format|
      format.html
      format.json {render :json => {'documents' => @documents, 'assignments' => @assignments, 'quizzes' => @quizzes}.to_json}
    end
  end
end