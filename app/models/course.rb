class Course < ActiveRecord::Base

# NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :post_id
    t.add :type 
  end

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    course = self.new
    course.module_id = params[:module_id].to_i
    course.post_id = params[:post_id].to_i
    course.type = params[:type]
    
    course
  end
end 
