class QuizAssignment < ActiveRecord::Base

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    quiz_assignment = self.new
    quiz_assignment.quiz_id = params[:post_id]
    quiz_assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
    quiz_assignment.diaspora_handle = params[:diaspora_handle]
    quiz_assignment
  end
end   