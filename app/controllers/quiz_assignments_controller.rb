class QuizAssignmentsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:index, :show, :create]
  respond_to :html, :json, :js

  def index    

    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end
	
  def show

    @quiz_assignment = QuizAssignment.find(params[:id])
    @quiz = Quiz.joins(:quiz_assignments).where('quiz_assignments.id' => @quiz_assignment.id).first
    @quiz[:questions] = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)

    @teacher_info = Person.includes(:profile).where(diaspora_handle: @quiz_assignment.diaspora_handle).first

    if current_user.role == "teacher"
      @authors = {}
      @quiz_assessments = QuizAssessment.where(:quiz_assignment_id => @quiz_assignment.id)
      unless @quiz_assessments.nil?
        @quiz_assessments.each { |c| @authors[c.id] = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first }
      end
    else
      @student = nil
      @quiz_assessment = QuizAssessment.where(:quiz_assignment_id => @quiz_assignment.id, :diaspora_handle => current_user.diaspora_handle).first              
      @student = Person.includes(:profile).where(diaspora_handle: @quiz_assessment.diaspora_handle).first unless @quiz_assessment.blank?      
    end  
  end

  def new
    @modules = Content.where(:aspect_id => params[:a_id])
    @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    
    respond_with do |format|
      format.html {render :layout => false}
    end 
  end

  def create
  	@quiz_assignment = current_user.build_post(:quiz_assignment, quiz_assignment_params)
  	if @quiz_assignment.save
      respond_to do |format|
        format.js
      end
    end
  end

  def quiz_assignment_params
    params.require(:quiz_assignment).permit(:quiz_id, :submission_date)
  end

  def publish
    
    @assignment = QuizAssignment.find(params[:a_id])
    if current_user.role == "teacher" and !@assignment.is_result_published      
      @quiz_assessments = QuizAssessment.where(:quiz_assignment_id => @assignment.id)
      unless @quiz_assessments.nil?
        @quiz_assessments.each { 
          |c| @recipient = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first
          opts = {}
          opts[:participant_ids] = @recipient.id
          opts[:message] = { text: "Quiz result has been published."}
          opts[:subject] = "Quiz published."
          @conversation = current_user.build_conversation(opts)

          if @conversation.save
            Postzord::Dispatcher.build(current_user, @conversation).post
          end
        }
        assessment_hash = {}
        assessment_hash[:is_result_published] = true
        @assignment.update_attributes!(assessment_hash)
      end
    end
    
    respond_to do |format|
      format.json { render :json => {"success" => true, "message" => 'Quiz published successfully.'} }
    end  
  end

  def performance
    @assignment_assessments = nil
    @assignment = QuizAssignment.find(params[:a_id])
    @data = []
    @data2 = []

    @temp = {}
    if current_user.role == "teacher"     
      @quiz_assessments = QuizAssessment.where(:quiz_assignment_id => @assignment.id)
      unless @quiz_assessments.nil?
        @quiz_assessments.each do |c|
          @data2.push([c.diaspora_handle, c.marks_obtained])
          @key = c.marks_obtained.to_s + " marks"
          @temp.has_key?(@key) ? @temp[@key] = @temp[@key] + 1 : @temp[@key] = 1          
        end
      end    
    end

    @temp.each { |key,value| @data.push([key, value])}
    Rails.logger.info(@data.to_json)
    Rails.logger.info(@data2.to_json)
    respond_to do |format|
      format.js {render :template => 'assignment_assessments/performance'}
    end
  end
end