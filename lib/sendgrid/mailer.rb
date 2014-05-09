module Sendgrid
  class Mailer
    def initialize(user_name, password, domain)
      Mail.defaults do
        delivery_method :smtp,
        {
          :address   => "smtp.sendgrid.net",
          :port      => 587,
          :user_name => user_name,
          :password  => password,
          :authentication => 'plain',
          :enable_starttls_auto => true,
          :domain    => domain # I usually set this as an env. var too
        }
      end
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
      begin
        Mail.deliver do
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
      rescue => e
        raise "Email send error #{e.message}"
      end  
    end
  end
end  
