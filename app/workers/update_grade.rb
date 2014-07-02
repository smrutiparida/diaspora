#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#message = ""
#if res.success?
#  message = "Grade published successfully!"
#elsif response.processing?
#elsif response.unsupported?  

module Workers
  class UpdateGrade < Base
    sidekiq_options queue: :update_grade

    def perform(provider, aspect)
      report_data = Report.where(:aspect_id => aspect.id)
      unless report_data.nil?
        max_score = report_data.maximum(:q_score)
        my_report = report_data.where(:person_id => aspect.user.person.id).first

        final_score = 0
        final_score = (my_report.q_score.to_f / max_score).round(2) if my_report and max_score > 0
        Rails.logger.info("final score is" + final_score.to_s)
        res = provider.post_replace_result!(final_score) 
        Rails.logger.info(res)  
      end 
    end  
  end
end


      

