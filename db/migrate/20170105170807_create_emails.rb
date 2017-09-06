class CreateEmails < ActiveRecord::Migration
    def change
        create_table :emails do |t|
            t.integer :user_id
            t.string :email
            t.boolean :primary, default: false

            ## Confirmable
            t.string   :confirmation_token
            t.datetime :confirmed_at
            t.datetime :confirmation_sent_at
            t.string   :unconfirmed_email # Only if using reconfirmable
          
            t.timestamps null: false
        end
    end
end
