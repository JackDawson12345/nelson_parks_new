class Admin::NotificationsController < ApplicationController
  def mark_as_seen
    current_user.notifications.where(seen: false).update_all(seen: true)

    head :ok
  end
end