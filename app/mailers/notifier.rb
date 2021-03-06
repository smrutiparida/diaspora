class Notifier < ActionMailer::Base
  helper :application
  helper :markdownify
  helper :notifier
  helper :people
  
  def self.admin(string, recipients, opts = {})
    mails = []
    recipients.each do |rec|
      mail = single_admin(string, rec, opts.dup)
      mails << mail
    end
    mails
  end

  def single_admin(string, recipient, opts={})
    @receiver = recipient
    @string = string.html_safe
    
    if attach = opts.delete(:attachments)
      attach.each{ |f|
        attachments[f[:name]] = f[:file]
      }
    end

    default_opts = {:to => @receiver.email,
         :from => AppConfig.mail.sender_address,
         :subject => I18n.t('notifier.single_admin.subject'),  :host => AppConfig.pod_uri.host}
    default_opts.merge!(opts)



    mail(default_opts) do |format|
      format.text
      format.html
    end
  end

  def course_invite_email(recipient_email, sender_id, aspect_id)
    @aspect = Aspect.find(aspect_id) if aspect_id.present?
    @sender = Person.find_by_id(sender_id) if sender_id.present?
    subject_string = @sender.name + " invited you to join a course on LMNOP"
    
    mail_opts = {:to => recipient_email, 
                 :from => AppConfig.mail.sender_address,
                 :subject => subject_string,
                 :host => AppConfig.pod_uri.host}
    
    mail_opts[:from] = "\"#{@sender.name} (lmnop)\" <#{AppConfig.mail.sender_address}>" if @sender.present?

    I18n.with_locale(locale) do
      mail(mail_opts) do |format|
        format.text
        format.html
      end
    end
  end

  def invite(email, message, inviter, invitation_code, locale)
    @inviter = inviter
    @message = message
    @locale = locale
    @invitation_code = invitation_code

    mail_opts = {:to => email, :from => AppConfig.mail.sender_address,
                 :subject => I18n.t('notifier.invited_you', :name => @inviter.name),
                 :host => AppConfig.pod_uri.host}

    I18n.with_locale(locale) do
      mail(mail_opts) do |format|
        format.text { render :layout => nil }
        format.html { render :layout => nil }
      end
    end
  end

  def started_sharing(recipient_id, sender_id)
    #send_notification(:started_sharing, recipient_id, sender_id)
  end

  def liked(recipient_id, sender_id, like_id)
    send_notification(:liked, recipient_id, sender_id, like_id)
  end

  def reshared(recipient_id, sender_id, reshare_id)
    send_notification(:reshared, recipient_id, sender_id, reshare_id)
  end

  def mentioned(recipient_id, sender_id, target_id)
    send_notification(:mentioned, recipient_id, sender_id, target_id)
  end

  def comment_on_post(recipient_id, sender_id, comment_id)
    send_notification(:comment_on_post, recipient_id, sender_id, comment_id)
  end

  def also_commented(recipient_id, sender_id, comment_id)
    send_notification(:also_commented, recipient_id, sender_id, comment_id)
  end

  def private_message(recipient_id, sender_id, message_id)
    send_notification(:private_message, recipient_id, sender_id, message_id)
  end

  def confirm_email(recipient_id)
    send_notification(:confirm_email, recipient_id)
  end

  def welcome_email(recipient_id)
    send_notification(:welcome_email, recipient_id)
  end

  def course_create_email(recipient_id, aspect_id)
    send_notification(:course_create_email, recipient_id, nil, aspect_id)
  end

  def student_digest_email(all_posts, user_email, aspect, user_name)
    @all_posts = all_posts
    
    @subject_string = "Daily Digest for course " + aspect + " as on " + Time.now.strftime("%d/%m/%Y").to_s
    #Rails.logger.info(@subject_string)
    @user_name = user_name

    mail_opts = {:to => user_email, 
                 :from => AppConfig.mail.sender_address,
                 :subject => @subject_string,
                 :host => AppConfig.pod_uri.host}

    I18n.with_locale(locale) do
      mail(mail_opts) do |format|
        format.text
        format.html
      end
    end
  end

  private
  def send_notification(type, *args)
    @notification = NotificationMailers.const_get(type.to_s.camelize).new(*args)

    with_recipient_locale do
      mail(@notification.headers) do |format|
        format.text
        format.html
      end
    end
  end

  def with_recipient_locale(&block)
    I18n.with_locale(@notification.recipient.language, &block)
  end

end
