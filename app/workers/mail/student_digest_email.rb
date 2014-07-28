module Workers
  module Mail
    class StudentDigestEmail < Base
      sidekiq_options queue: :digest_email
      def perform(all_posts, user_email, aspect, user_name)
      	Rails.logger.info("came here")
        Notifier.student_digest_email(all_posts, user_email, aspect, user_name).deliver
      end
    end
  end
end 	