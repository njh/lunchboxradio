# For details on Sequel migrations see 
# http://sequel.rubyforge.org/
# http://code.google.com/p/ruby-sequel/wiki/Migrations

class CreateRadioStreams < Sequel::Migration

  def up
    create_table :radio_streams do
      primary_key :id
      column :location, :text
      column :title, :text
      column :creator, :text
      column :annotation, :text
      column :created_at, :timestamp
    end
  end

  def down
    drop_table :radio_streams
  end

end
