module Workers
  class SendCourseInviteEmail < Base
    sidekiq_options queue: :mail
	  
    def perform(recepient_email, sender_id, aspect_id)
      Notifier.course_invite_email(recepient_email, sender_id, aspect_id).deliver
    end
  end
end
