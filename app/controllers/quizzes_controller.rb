class QuizzesController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :index, :show,:create]
  respond_to :html, :json, :js

  def new
    respond_to do |format|
      format.html 
    end
  end

  def index    
    @modules = Content.where(:aspect_id => params[:a_id])
    @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    
    respond_with do |format|
      format.html {render :layout => false}
      format.json {render :json => @quizzes.to_json}
    end    
  end

  def show
    @quiz = Quiz.find(params[:id])
    @quiz[:questions] = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)
    @role = Role.where(:person_id => current_user.person, :name => 'teacher').first
    #layout_option = (@role.nil? or @role.name != "teacher") ? true : false
    layout_option = params[:overlay] == "1" ? false : true
    #Rails.logger.info(@quiz[:questions].to_json)
    #Rails.logger.info(@quiz.to_json)
    respond_with do |format|
      format.html {render :layout => layout_option}
      format.json {render :json => @quiz.to_json}
    end
    raise ActiveRecord::RecordNotFound unless @quiz
  end

  def create
    #@params = params[:quiz][:quiz_questions_attributes]
    #@student_group = @quiz.quiz_questions.build(params[:student_group])
    @quiz = current_user.build_post(:quiz, params[:quiz])
    
    #@quiz.quiz_questions.build
    Rails.logger.info(@quiz.to_json)
    if @quiz.save!
      #questions = questions_from_ids(params[:quiz_question])
      #add_to_quizset(@quiz, questions)
      #@response = {}
      @response = @quiz.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Quiz created successfully."
    else
      @response[:success] = true
      response[:message] = "Quiz creation failed. Please try again!"  
    end  
   
    respond_to do |format|
      format.js
    end  
  end  

  #def quiz_params
  #  params.require(:quiz).permit(:public, :title,:randomize_questions,:submission_date,:total_marks,:quiz_question_attributes => [:marks], :question_attributes => [:id])
  #end

  private 

  #def questions_from_ids(questions)
  #  Question.where(:id => aspect_ids)
  #end
  
end  