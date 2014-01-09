class QuizAssessment < ActiveRecord::Base
  
  belongs_to :quiz_assignment, :foreign_key => :quiz_id, :primary_key => :id

  
end   