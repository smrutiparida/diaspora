class Question < ActiveRecord::Base
  
  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at  
    t.add :author    
    t.add :description
    t.add :type
    t.add :correct_answer
    t.add :all_answers
  end

  delegate :author_name, to: :current_user, prefix: true

  before_destroy :ensure_user_question
  after_destroy :clear_empty_status_message

  def clear_empty_status_message
   
      true
   
  end

  def self.diaspora_initialize(params = {})
    question = self.new
    question.description = params[:description]
    question.type = params[:type]
    question.answer = params[:answer]    
    question.diaspora_handle = question.author.diaspora_handle

    question.all_answers = case question.type
      when "true_false"
        question.all_answers = ""
      when "fill_in_blanks"
        question.all_answers = ""
      when "multiple_choice"
        question.all_answers = params[:all_answers]
      else
        question.all_answers = ""        
    end  

    question
  end
 
end
