class AddNotificationsDisabledToNews < ActiveRecord::Migration[6.1]
  def change
    add_column :news, :notifications_disabled, :boolean, default: :false
  end
end
