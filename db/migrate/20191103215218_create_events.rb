class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.references :user, foreign_key: true
      t.integer :kind, null: false
      t.datetime :stamp, default: -> { 'CURRENT_TIMESTAMP' }
      
      t.string :comment

      t.timestamps
    end
  end
end
