
class Dialog
  def initialize(hash=nil)
    @data = {}
    @data.merge!(hash) unless hash.nil?
  end

  def to_html
    # FIXME: re-factor this to use templates
    html = StringIO.new
    html.puts "<h1>#{@data['title']}</h1>" unless @data['title'].nil?
    html.puts "<p>#{@data['caption']}</h1>" unless @data['caption'].nil?
    
    case @data['type']
      when 'menu'
        html.puts "<ul>"
        @data['items'].each do |item|
          html.puts "<li><a href='#{item['href']}'>#{item['title']}</a></li>"
        end
        html.puts "</ul>"
      when 'msgbox'
        html.puts "<p>#{@data['text']}</p>"
      else
        html.puts "<p>Unsupported dialog type: #{@data['type']}</p>"
    end
    html.string
  end
  
  def to_yaml
    @data.to_yaml
  end
end
