
class Dialog
  def initialize(hash=nil)
    @data = {}
    @data.merge!(hash) unless hash.nil?
  end

  def to_html
    # FIXME: re-factor this to use templates
    html = StringIO.new
    html.puts "<p>#{@data['caption']}</h1>" unless @data['caption'].nil?
    
    case @data['type']
      when 'menu'
        html.puts "<ul>"
        @data['items'].each do |item|
          next if item['href'] =~ /^ruby:/
          html.print "<li>"
          html.print "<a href='#{item['href']}'>" unless item['href'].nil?
          html.print item['title']
          html.print "</a>" unless item['href'].nil?
          html.puts "</li>"
        end
        html.puts "</ul>"
      when 'msgbox'
        html.puts "<p>#{@data['text']}</p>"
      else
        html.puts "<p>Unsupported dialog type: #{@data['type']}</p>"
    end
    html.string
  end
  
  def [] (key)
    @data[key]
  end
  
  def to_yaml
    @data.to_yaml
  end
end
