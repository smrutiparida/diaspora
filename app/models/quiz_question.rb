class QuizQuestion < ActiveRecord::Base

  belongs_to :quiz
  belongs_to :question
  accepts_nested_attributes_for :question

  #before_destroy do
  #  if self.contact && self.contact.aspects.size == 1
  #    self.user.disconnect(self.contact)
  #  end
  #  true
  #end

  def as_json(opts={})
    {
      :id => self.id,
      :quiz_id  => self.quiz_id,
      :question_ids => self.quiz.questions.map{|q| q.id}
    }
  end

  def << (sharedobjects)    
    Rails.logger.info(sharedobjects.to_json)
    self.quiz_questions << sharedobjects
  end
  
end



