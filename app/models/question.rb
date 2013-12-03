class Question < ActiveRecord::Base
  
  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at  
    t.add :description
    t.add :type
    t.add :answer
    t.add :all_answers
  end

  delegate :author_name, to: :current_user, prefix: true

  belongs_to :user

  belongs_to :person
  validates :person, :presence => true

  before_destroy :ensure_user_question
  after_destroy :clear_empty_status_message

  scope :for_a_stream, lambda {
    includes(:questions).
        order('questions.updated_at DESC')
  }

  def clear_empty_status_message
   
      true
   
  end

  def self.diaspora_initialize(params = {})
    question = self.new
    question.description = params[:description]
    question.type = params[:type]
    question.answer = params[:answer]    
    question.diaspora_handle = params[:author].diaspora_handle    
        
    question.all_answers = case question.type
      when "true_false"
        question.all_answers = ""
      when "fill_in_blanks"
        question.all_answers = ""
      when "multiple_choice"
        question.all_answers = { 'answer1' => params[:answer1],
                                 'answer2' => params[:answer2],
                                 'answer3' => params[:answer3] ,
                                 'answer4' => params[:answer4]
                                }.to_json                                 
      else
        question.all_answers = ""        
    end  

    question
  end
 
end
