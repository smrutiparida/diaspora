class QuizAssignment < ActiveRecord::Base
  
  belongs_to :quiz, :foreign_key => :quiz_id, :primary_key => :id

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    quiz_assignment = self.new
    quiz_assignment.quiz_id = params[:quiz_id]
    quiz_assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
    quiz_assignment.diaspora_handle = params[:diaspora_handle]
    quiz_assignment
  end
end   