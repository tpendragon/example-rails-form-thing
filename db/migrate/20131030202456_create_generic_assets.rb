class CreateGenericAssets < ActiveRecord::Migration
  def change
    create_table :generic_assets do |t|
      t.string :main_title
      t.string :alternate_title
      t.string :type
      t.string :subjects
      t.string :creator
      t.string :photographer
      t.string :author

      t.timestamps
    end
  end
end
