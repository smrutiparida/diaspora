class Course < ActiveRecord::Base

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    course = self.new
    course.module_id = params[:module_id].to_i
    course.post_id = params[:post_id].to_i
    course.type = params[:type]
    
    course
  end
end 
