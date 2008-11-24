class Streams < Application
  provides :html, :dlg
  

  def index
    latest_stream = RadioStream.order(:created_at).last
    #if latest_stream.nil? or latest_stream.created_at < 
      # Tell user that we need to fetch a list of streams
      # then redirect them to 'fetch' action
    #
    
    # Display the list of streams
    streams = RadioStream.order(:id).all
    dialog = Dialog.new(
      'type' => 'menu',
      'title' => 'Live Radio Streams',
      'items' => streams.map {|s| {'title' => s.title} }
    )

    display dialog, :layout => "application"
  end
  
  def fetch
    RadioStream.fetch
    redirect('/streams')
  end
  
  def select
  
  end

end
