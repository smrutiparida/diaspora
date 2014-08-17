module Workers
  class SendCourseCreateEmail < Base
    sidekiq_options queue: :mail
	  
    def perform(user_id, aspect_id)
      Notifier.course_create_email(user_id, aspect_id).deliver
    end
  end
end
