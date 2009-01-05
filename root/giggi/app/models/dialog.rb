class Dialog
  def initialize(hash=nil)
    @data = {}
    @data.merge!(hash) unless hash.nil?
  end

  def html_template
    "dialogs/#{@data['type']}.html.erb"
  end
  
  def [] (key)
    @data[key]
  end
  
  def to_yaml
    @data.to_yaml
  end
end
