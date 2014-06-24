class Notifications::StartedSharing < Notification
  # All methods return NIL as #Smruti decide to not send any notification for users joining a course group.
  def mail_job
    return nil
    Workers::Mail::StartedSharing
  end

  def popup_translation_key
    'notifications.started_sharing'
  end

  def email_the_user(target, actor)
    return nil
    super(target.sender, actor)
  end

  private

  def self.make_notification(recipient, target, actor, notification_type)
    return nil
    super(recipient, target.sender, actor, notification_type)
  end

end
