class CreateNetworks < ActiveRecord::Migration

  def self.up
    create_table :networks do |t|
      t.string  :name, :text
      t.string  :medium, :text, :default => 'wifi'
      t.string  :wireless_security, :text, :default => 'none'
      t.string  :wireless_key, :text
      t.string  :ip_method, :text, :default => 'dhcp'
      t.string  :ip_address, :text
      t.string  :ip_netmask, :text
      t.string  :ip_gateway, :text
      t.string  :ip_domain, :text
      t.string  :ip_dnsservers, :text
      t.timestamps
    end
    add_index :networks, :name, :unique => true
    
    Network.create(
      :name => 'Ethernet',
      :medium => 'ethernet',
      :wireless_security => 'none',
      :ip_method => 'dhcp'
    )
  end

  def self.down
    drop_table :networks
  end

end
