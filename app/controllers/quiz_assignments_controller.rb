class QuizAssignmentsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:index, :show, :create]
  respond_to :html, :json, :js

  def index    
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    @courses = current_user.aspects
    respond_to do |format|
      format.html
    end
  end
	
  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    @quiz_assignment = QuizAssignment.find(params[:id)
    @quiz = Quiz.joins(:quiz_assignments).where('quiz_assignments.id' => @quiz_assignment.id).first
    @quiz[:questions] = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)

    @teacher_info = Person.includes(:profile).where(diaspora_handle: @assignment.diaspora_handle).first

    if @teacher
      @authors = {}
      @quiz_assessments = QuizAssessment.where(:quiz_id => @quiz_assignment.id)
      unless @quiz_assessments.nil?
        @quiz_assessments.each { |c| @authors[c.id] = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first }
      end
    else
      @student = nil
      @quiz_assessment = QuizAssessment.where(:quiz_id => @quiz_assignment.id, :diaspora_handle => current_user.diaspora_handle).first              
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
end