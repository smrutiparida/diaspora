class QuizQuestionsAssessment < ActiveRecord::Base

  belongs_to :quiz_assessment
  
  #before_destroy do
  #  if self.contact && self.contact.aspects.size == 1
  #    self.user.disconnect(self.contact)
  #  end
  #  true
  #end

  def << (sharedobjects)    
    #Rails.logger.info(sharedobjects.to_json)
    self.quiz_questions_assessments << sharedobjects
  end
  
end