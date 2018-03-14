class CreateRobots < ActiveRecord::Migration[5.1]
  def change
    create_table :robots do |t|
      t.string :title
      t.decimal :price
      t.string :avatar

      t.timestamps
    end
  end
end
