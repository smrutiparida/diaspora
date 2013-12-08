class LibraryController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :json, :js

  def index
    @documents = Document.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    @assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
        
    respond_to do |format|
      format.html
      format.json {render :json => {'documents' => @documents, 'assignments' => @assignments, 'quizzes' => @quizzes}.to_json}
    end
  end
end  
