class Notification < ApplicationRecord
  belongs_to :user

  def self.send_notification(user_id, title, text)
    if user_id == 'Admins'
      User.where(admin: true).find_each do |user|
        create!(
          user: user,
          title: title,
          text: text
        )
      end
    else
      create!(
        user_id: user_id,
        title: title,
        text: text
      )
    end
  end
end