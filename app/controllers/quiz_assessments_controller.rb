class QuizAssessmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :index, :destroy, :show, :update, :publish, :performance]
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
    @assignment_assessment = AssignmentAssessment.find(params[:id])
    Rails.logger.info(@assignment_assessment.to_json)
    assessment_hash = assignment_assessment_params
    assessment_hash[:points] = assessment_hash[:points].to_i
    assessment_hash[:is_checked] = true
    assessment_hash[:checked_date] = Time.now
    Rails.logger.info(assessment_hash.to_json)

    if @assignment_assessment.update_attributes!(assessment_hash)
      redirect_to '/assignment_assessments/' + @assignment_assessment.assignment_id.to_s + '?s_id=' + @assignment_assessment.id.to_s
    else
      flash[:error] = I18n.t 'aspects.update.failure', :name => @aspect.name
    end    
  end

  def show
    role = Role.where(:person_id => current_user.person.id, :name => 'teacher').first
    @teacher = role.nil? ? false : true

    @quiz_assignment = QuizAssignment.find(params[:id)
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
    # When a user attempts a quiz and eventually submits it, this function is calles
    # for each question in a quiz
      # find if the answer submitted by the user is same as the correct answe
      # insert a record in quiz_questions_assessment , hold a variable to calcualte the correct marks_obtained
    # insert a record in quiz_assessments recording the total_marks and submission_time  
  end

  private

   
  def quiz_assessment_params
    params.require(:quiz_assessment).permit(:marks)
  end
end