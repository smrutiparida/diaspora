module Workers
  module Mail
    class StudentDigestEmail < Base
      sidekiq_options queue: :digest_email
      def perform(all_posts, user, aspect)
        Notifier.student_digest_email(all_posts, user, aspect).deliver
      end
    end
  end
end 	