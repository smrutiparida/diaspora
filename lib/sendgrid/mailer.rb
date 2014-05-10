module Sendgrid
  class Mailer
    def initialize()
      
    end  

    attr_accessor :settings

    def new(*settings)
      self.settings = {}
      self
    end
   
    def deliver(message)
      deliver!(message)
    end

    def deliver!(message)
      Rails.logger.info(AppConfig.mail.sendgrid.user_name)
      Mail.defaults do
        delivery_method :smtp,
        {
          :address   => "smtp.sendgrid.net",
          :port      => 587,
          :user_name => AppConfig.mail.sendgrid.user_name,
          :password  => AppConfig.mail.sendgrid.password,
          :authentication => 'plain',
          :enable_starttls_auto => false,
          :domain    => AppConfig.mail.sendgrid.domain
        }
      end
      begin
        mail = Mail.deliver do
          from AppConfig.mail.sender_address
          to message.to.first
          subject message.subject
          text_part do
            body message.body.to_s
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body message.body.to_s
          end
        end
        Rails.logger.info(mail)
      rescue => e
        raise "Email send error #{e.message}"
      end  
      
    end
  end
end  
