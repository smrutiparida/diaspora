class QuizAssessmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:create, :new, :destroy, :show, :update]
  respond_to :html, :json, :js

  def update
  end
  
  def new
    @quiz_assignment = QuizAssignment.find(params[:id])
    @quiz = Quiz.joins(:quiz_assignments).where('quiz_assignments.id' => @quiz_assignment.id).first
    @quiz[:questions] = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)

    respond_to do |format|
      format.html {render :layout => false} 
    end  
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    @quiz_assignment = QuizAssignment.find(params[:id])
    @quiz_assessment = QuizAssessment.where(:quiz_id => @quiz_assignment.id, :diaspora_handle => current_user.diaspora_handle).first
    @quiz = Quiz.joins(:quiz_assignments).where('quiz_assignments.id' => @quiz_assignment.id).first

    @quiz[:questions] = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)
    @quiz[:answers] = QuizQuestionsAssessment.where(:quiz_assessment_id => @quiz_assessment.id )
    
    respond_to do |format|
      format.js
      format.any(:json, :html) { render }
    end
  end

  def create
    @quiz_assignment = QuizAssignment.find(params[:quiz_assignment_id])
    @quiz = Quiz.find(@quiz_assignment.quiz_id)
    @questions = Question.joins(:quiz_questions).where('quiz_questions.quiz_id' => @quiz.id)
    question_hash = {}
    @questions.each {|question| question_hash[question.id.to_i] = question}
    
    @quiz_assessment = current_user.build_post(:quiz_assessment, params[:quiz_assessment])
    #Rails.logger.info(@quiz_assessment.to_json)
    @quiz_assessment.quiz_assignment_id = @quiz_assignment.id
    @quiz_assessment.highest_marks_obtained = @quiz.total_marks
    
    @quiz_assessment.marks_obtained = 0
    
    @quiz_assessment.quiz_questions_assessments.each do |quiz_answer|
      answer_set = question_hash[quiz_answer.quiz_question_id]
      #Rails.logger.info(answer_set.answer)
      #Rails.logger.info(answer_set.answer.downcase + ',' + quiz_answer.answer.downcase)
      if answer_set.answer.downcase.strip == quiz_answer.answer.downcase.strip
        quiz_answer.marks = answer_set.mark
        @quiz_assessment.marks_obtained += quiz_answer.marks
      else
        quiz_answer.marks = 0
      end  
    end  

    if @quiz_assessment.save
      respond_to do |format|
        format.js
      end
    end
  end
end