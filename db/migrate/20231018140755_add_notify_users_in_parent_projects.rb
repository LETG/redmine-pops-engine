class AddNotifyUsersInParentProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :notify_users_in_parent_projects, :boolean
    add_column :news,      :notify_users_in_parent_projects, :boolean
  end
end
