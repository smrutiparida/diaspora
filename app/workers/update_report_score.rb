#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class UpdateReportScore < Base
    sidekiq_options queue: :update_score

    def perform(post, type)
      aspect = current_user.aspects.where(:id => params[:a_id]).first
      teacher = User.find(teacher_id)
      teacher_aspect = teacher.aspects.where(:name => aspect.name).first
      if type == "comment" and current_user.role != "teacher"
        report_obj = Report.find_by_aspect_id_and_person_id( teacher_aspect.id, current_user.person_id) || Report.new(:aspect_id => teacher_aspect.id, :person_id => current_user.person_id, :name => current_user.name, :q_answered => 0, :q_score => 0)
        report_obj.q_answered += 1
        report_obj.q_score += 1
        report_obj.save
      elsif type == "resolve"
        report_obj = Report.find_by_aspect_id_and_person_id(teacher_aspect.id, @comment.author_id)
        report_obj.q_resolved += 1        
        report_obj.q_score += 1
        report_obj.save
      end  
    end
  end
end