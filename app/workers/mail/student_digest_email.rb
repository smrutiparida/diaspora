module Workers
  module Mail
    class StudentDigestEmail < Base
      sidekiq_options queue: :digest_email
      def perform(all_posts, user, aspect)
      	Rails.logger.info("came here")
        Notifier.student_digest_email(all_posts, user.email, aspect, user.first_name).deliver
      end
    end
  end
end 	