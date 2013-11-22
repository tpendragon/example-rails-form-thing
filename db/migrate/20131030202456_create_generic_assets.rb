class CreateGenericAssets < ActiveRecord::Migration
  def change
    create_table :generic_assets do |t|
      t.string :main_title
      t.string :alt_title
      t.string :parallel_title
      t.string :series

      t.string :creator
      t.string :photographer
      t.string :author

      t.string :subjects

      t.string :asset_type

      t.string :admin_replaces
      t.string :original_full_asset_path
      t.string :admin_conversion_spec

      t.timestamps
    end
  end
end
