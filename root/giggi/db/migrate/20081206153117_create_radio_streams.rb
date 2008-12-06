class CreateRadioStreams < ActiveRecord::Migration

  def self.up
    create_table :radio_streams do |t|
      t.string :location, :text
      t.string  :title, :text
      t.string  :creator, :text
      t.string  :annotation, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :radio_streams
  end

end
