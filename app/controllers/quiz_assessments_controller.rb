class QuizAssessmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:create, :new, :destroy, :show, :update, :publish, :performance]
  respond_to :html, :json, :js


  def publish
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment_assessments = nil
    @assignment = Assignment.find(params[:a_id])
    if @teacher and !@assignment.is_result_published      
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      unless @assignment_assessments.nil?
        @assignment_assessments.each { 
          |c| @recipient = Person.includes(:profile).where(diaspora_handle: c.diaspora_handle).first
          opts = {}
          opts[:participant_ids] = @recipient.id
          opts[:message] = { text: "Assignment result has been published."}
          opts[:subject] = "Assignment published."
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
      format.json { render :json => {"success" => true, "message" => 'Assignment published successfully.'} }
    end  
  end

  def performance
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true
    @assignment_assessments = nil
    @assignment = Assignment.find(params[:a_id])
    @data = []
    @data2 = []
    @temp = {}
    if @teacher      
      @assignment_assessments = AssignmentAssessment.where(:assignment_id => @assignment.id)
      unless @assignment_assessments.nil?
        @assignment_assessments.each do |c|
          c.is_checked ? @data2.push([c.diaspora_handle, c.points]) : next
          @key = c.points.to_s + " marks"
          @temp.has_key?(@key) ? @temp[@key] = @temp[@key] + 1 : @temp[@key] = 1          
        end
      end    
    end

    @temp.each { |key,value| @data.push([key, value])}
    Rails.logger.info(@data.to_json)
    Rails.logger.info(@data2.to_json)
    respond_to do |format|
      format.js
    end
  end

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
    @questions.each {|question| question_hash[question.id.to_i] = question.attributes}
    
    Rails.logger.info(question_hash.to_json)

    @quiz_assessment = current_user.build_post(:quiz_assessment, params[:quiz_assessment])
    Rails.logger.info(@quiz_assessment.to_json)
    @quiz_assessment.quiz_assignment_id = @quiz_assignment.id
    
    @quiz_assessment.marks_obtained = 0
    
    @quiz_assessment.quiz_questions_assessments.each do |quiz_answer|
      answer_set = question_hash[quiz_answer.quiz_question_id]
      Rails.logger.info(answer_set.answer)
      Rails.logger.info(answer_set.answer.downcase + ',' + quiz_answer.answer.downcase)
      if answer_set[:answer].downcase == quiz_answer.answer.downcase
        quiz_answer.marks = answer_set[:mark]
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
    
    # When a user attempts a quiz and eventually submits it, this function is calles
    # for each question in a quiz
      # find if the answer submitted by the user is same as the correct answe
      # insert a record in quiz_questions_assessment , hold a variable to calcualte the correct marks_obtained
    # insert a record in quiz_assessments recording the total_marks and submission_time  
  end

  private

  
end