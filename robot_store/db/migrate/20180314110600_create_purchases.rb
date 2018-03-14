class CreatePurchases < ActiveRecord::Migration[5.1]
  def change
    create_table :purchases do |t|
      t.integer :value
      t.belongs_to :user
      t.belongs_to :robot

      t.timestamps
    end
  end
end
