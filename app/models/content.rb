class Content < ActiveRecord::Base

  def self.diaspora_initialize(params = {})
    Rails.logger.info("Model Enter")
    new_module = self.new
    new_module.name = params[:name]
    new_module.aspect_id = params[:a_id].to_i
    
    new_module
  end
end  