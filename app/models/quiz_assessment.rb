class QuizAssessment < ActiveRecord::Base
  
  belongs_to :quiz_assignment, :foreign_key => :quiz_assignment_id, :primary_key => :id
  has_many :quiz_questions_assessments, :foreign_key => :quiz_assessment_id, :dependent => :destroy
  
  def self.diaspora_initialize(params = {})
    quiz_assessment = self.new #params.to_hash.slice(:name, :description, :submission_date)
    quiz_assessment.diaspora_handle = params[:author].diaspora_handle
    quiz_assessment.attempted_on = Time.now
    
    quiz_assessment.quiz_questions_assessments.build(params[:quiz_questions_assessments_attributes])
    quiz_assessment
  end

  
end   