class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      # t.trackable
      # t.encryptable
      # t.confirmable
      # t.lockable lock_strategy: :failed_attempts, unlock_strategy: :both
      # t.token_authenticatable
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    # add_index :users, :authentication_token, unique: true
  end

end
