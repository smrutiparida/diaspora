class Quiz < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id    
    t.add :created_at    
    t.add :author
    t.add :public
    t.add :title
    t.add :total_marks            
    t.add :randomize_questions
  end

  has_many :quiz_questions, :dependent => :destroy
  has_many :questions, :through => :quiz_questions
  accepts_nested_attributes_for :quiz_questions

  #belongs_to :status_message, :foreign_key => :status_message_guid  , :primary_key => :guid
  #validates_associated :status_message
  #delegate :author_name, to: :status_message, prefix: true

  #validate :ownership_of_status_message

  #before_destroy :ensure_user_assignment
  #after_destroy :clear_empty_status_message

  #def clear_empty_status_message
  #  if self.status_message_guid && self.status_message.text_and_photos_and_documents_blank_and_assignments_blank?
  #    self.status_message.destroy
  #  else
  #    true
  #  end
  #end

  #def ownership_of_status_message
  #  message = StatusMessage.find_by_guid(self.status_message_guid)
  #  if self.status_message_guid && message
  #    self.diaspora_handle == message.diaspora_handle
  #  else
  #    true
  #  end
  #end

  def self.diaspora_initialize(params = {})
    quiz = self.new #params.to_hash.slice(:name, :description, :submission_date)
    quiz.author = params[:author]
    quiz.public = params[:public] if params[:public]
    quiz.title = params[:title]
    quiz.total_marks = params[:total_marks]    
    quiz.randomize_questions = false unless params[:randomize_questions]
            
    quiz
  end

  def << (sharedobjects)    
    Rails.logger.info(sharedobjects.to_json)
    self.quiz_questions << sharedobjects
  end


end  
  