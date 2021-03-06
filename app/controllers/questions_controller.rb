class QuestionsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index, :show, :clone]
  respond_to :html, :json, :js

  def new  
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end
  
  def index
    @questions = Question.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at) 
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end 
  end

  def show  
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html do
        render :layout => false
      end
      format.js
    end    
  end
  def clone
    @question = Question.find(params[:id])
    respond_to do |format|
      format.js   { render :action => "create"}  #rails now looks for create.js.erb
    end
  end
  def create
    @question = current_user.build_post(:question, question_params)
    
    if @question.save!      
      #@response = {}
      @response = @question.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Question created successfully."
    else
      @response = {}
      @response[:success] = true
      @response[:message] = "Question creation failed. Please try again!"  
    end  
   
    respond_to do |format|
      format.js
    end  
  end  

  def question_params
    params.require(:question).permit(:description,:qtype,:mark,:answer,:answer1, :answer2,:answer3,:answer4, :tags)
  end
end