class QuizAssignment < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

 # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id    
    t.add :submission_date
    t.add :title
    t.add :total_marks
    t.add lambda { |quiz_assignment|
            quiz_assignment.subdate(quiz_assignment.submission_date)
          }, :as => :sub_date             

    t.add lambda { |quiz_assignment|
            quiz_assignment.submonth(quiz_assignment.submission_date)
          }, :as => :sub_month    
  end 

  belongs_to :quiz, :foreign_key => :quiz_id, :primary_key => :id
  delegate :title, :total_marks, to: :quiz
  belongs_to :status_message, :foreign_key => :status_message_guid  , :primary_key => :guid
  validates_associated :status_message

  def subdate(date = nil)    
    if date
      Rails.logger.info(date.to_s)
      DateTime.parse(date.to_s).strftime("%d")
    end
  end
  
  def submonth(date = nil)    
    if date
      Rails.logger.info(date.to_s)
      DateTime.parse(date.to_s).strftime("%b")
    end
  end
  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    quiz_assignment = self.new
    quiz_assignment.quiz_id = params[:quiz_id]
    quiz_assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
    #quiz_assignment.author = params[:author]
    quiz_assignment.diaspora_handle = params[:diaspora_handle]
    quiz_assignment.public = params[:public] if params[:public]

    quiz_assignment
  end
end   