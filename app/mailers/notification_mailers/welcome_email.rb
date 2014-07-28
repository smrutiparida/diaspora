module NotificationMailers
  class WelcomeEmail < NotificationMailers::Base
    def set_headers
      @headers[:to] = name_and_address(@recipient.first_name, @recipient.unconfirmed_email)
      @headers[:subject] = I18n.t('notifier.welcome_email.subject')
    end
  end
end