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
  end

  def show
    @quiz = if user_signed_in?
      current_user.quizzes_from(Person.find_by_guid(params[:person_id])).where(id: params[:id]).first
    else
      Quiz.where(id: params[:id], public: true).first
    end

    raise ActiveRecord::RecordNotFound unless @quiz
  end

  def create
    @quiz = current_user.build_post(:quiz, quiz_params)
    if @quiz.save      
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

  def quiz_params
    params.require(:quiz).permit(:public, :text,:submission_date,:total_marks,:submission_date, quiz_question_attributes => [:marks,quiz_attributes => [:quiz_id]])
  end

  private 

  def get_question_bank
  	@quizzes = Question.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
	  #@quizzes = @quizzes.for_a_stream.paginate(:page => params[:page], :per_page => 100)
    #@questions_size = @questions.length
  end	
end  