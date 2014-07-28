module Workers
  module Mail
    class SendWelcomeEmail < Base
      sidekiq_options queue: :mail
      
      def perform(user_id)
        Notifier.welcome_email(user_id).deliver
      end
    end
  end
end
