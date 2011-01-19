class AddUsersLastRequestAt < ActiveRecord::Migration
  def self.up
    add_column('users', 'last_request_at', :datetime)
    add_column('users', 'privs', :text)
    add_column('users', 'enabled', :boolean)
  end

  def self.down
    remove_column('users', 'last_request_at')
    remove_column('users', 'privs')
    remove_column('users', 'enabled')
  end
end
