class QuizzesController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :index, :show,:create]
  respond_to :html, :json, :js

  def new
  	#@quizzes = get_question_bank
    @quiz = Quiz.new
    @quizzes = Question.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  

    respond_to do |format|

      # Used for normal requests to contacts#index and subsequent infinite scroll calls
      format.html 
      # Used by the mobile site
      format.mobile { get_question_bank }

      # Used to populate mentions in the publisher
      format.json {
      #  aspect_ids = params[:aspect_ids] || current_user.aspects.map(&:id)
      #  @people = Person.all_from_aspects(aspect_ids, current_user).for_json
      #  render :json => @people.to_json
      }
    end
  end

  def index
    @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    
    respond_with do |format|
      format.html {render :layout => false}
      format.json {render :json => @quizzes.to_json}
    end
  end  

  def show
    @quiz = Quiz.where(:diaspora_handle => current_user.diaspora_handle, id: params[:id]).first
    @quiz.questions = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)
    
    respond_with do |format|
      format.html {render :layout => false}
      format.json {render :json => @quiz.to_json}
    end
    raise ActiveRecord::RecordNotFound unless @quiz
  end

  def create
    #@params = params[:quiz][:quiz_questions_attributes]
    #@student_group = @quiz.quiz_questions.build(params[:student_group])
    @quiz = current_user.build_post(:quiz, params[:quiz])
    Rails.logger.info(params.to_json)
    #@quiz.quiz_questions.build
    Rails.logger.info(@quiz.to_json)
    if @quiz.save!
      #questions = questions_from_ids(params[:quiz_question])
      #add_to_quizset(@quiz, questions)
      #@response = {}
      @response = @quiz.as_api_response(:backbone)
      @response[:success] = true
      @response[:message] = "Assignment created successfully."
    else
      @response[:success] = true
      response[:message] = "Assignment creation failed. Please try again!"  
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
  
  def get_question_bank
  	@quizzes = Question.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
	  #@quizzes = @quizzes.for_a_stream.paginate(:page => params[:page], :per_page => 100)
    #@questions_size = @questions.length
  end	
end  