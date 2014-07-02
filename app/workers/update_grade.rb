#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class UpdateGrade < Base
    sidekiq_options queue: :update_grade

    def perform(provider, aspect)
      report_data = Report.where(:aspect_id => aspect.id)
      unless report_data.nil?
        max_score - report_data.maximum(:q_score)
        my_report = report_data.where(:person_id => aspect.user.person.id).first

        
        #report_data.each do |r|
          #@data2.push([r.name, r.q_asked, r.q_answered, r.q_resolved, r.q_score])
        
        #end
        if my_report
          res = provider.post_replace_result!(my_report.q_score / max_score) 
          Rails.logger.info(res)

        end  
      end 

      #message = ""
      #if res.success?
      #  message = "Grade published successfully!"
      #elsif response.processing?
      #elsif response.unsupported?  
      

      
    end  
  end
end