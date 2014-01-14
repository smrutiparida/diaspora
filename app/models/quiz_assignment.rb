class QuizAssignment < ActiveRecord::Base
 
 # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id    
    t.add :submission_date              
  end 

  belongs_to :quiz, :foreign_key => :quiz_id, :primary_key => :id
  delegate :title, :total_marks, to: :quiz
  belongs_to :status_message, :foreign_key => :status_message_guid  , :primary_key => :guid
  validates_associated :status_message

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    quiz_assignment = self.new
    quiz_assignment.quiz_id = params[:quiz_id]
    quiz_assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
    quiz_assignment.author = params[:author]
    quiz_assignment.diaspora_handle = quiz_assignment.author.diaspora_handle

    quiz_assignment
  end
end   