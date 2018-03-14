class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.string :txid
      t.integer :value
      t.integer :included_in_block
      t.belongs_to :user

      t.timestamps
    end
  end
end
