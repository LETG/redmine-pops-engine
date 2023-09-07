class AddNotificationsDisabledToDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :notifications_disabled, :boolean
  end
end
