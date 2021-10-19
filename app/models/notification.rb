class Notification < ActiveRecord::Base
  belongs_to :user

  validates :message, presence: true
  validates :user_id, presence: true

  def self.send_notification(receiver, type, sender_name)
    message      = make_message(type, sender_name)
    notification = receiver.notifications.create(message: message, 
                     notification_type: type, sender: sender_name)
    receiver.update_new_notifications

    # Send Event to receiver, then send an email
    notification.send_notification_email
  end

  def self.make_message(type, sender)
    case type.to_s.downcase
    when "request" then "#{sender} sent you a Friend Request"
    else "Default Notification"
    end
  end

  def send_notification_email
    if user.profile.email_notification
      UserMailer.notification_email(self).deliver
    end
  end

end
