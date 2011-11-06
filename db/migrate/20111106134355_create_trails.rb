class CreateTrails < ActiveRecord::Migration
  def change
    create_table :trails do |t|
      t.string :longitude_start
      t.string :latitude_start
      t.string :longitude_end
      t.string :latitude_end
      t.string :lat_map
      t.string :gmap

      t.timestamps
    end
  end
end
