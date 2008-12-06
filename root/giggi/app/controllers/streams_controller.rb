class StreamsController < ApplicationController

  def index
    latest_stream = RadioStream.last(:order => 'created_at')
    #if latest_stream.nil? or latest_stream.created_at < 
      # Tell user that we need to fetch a list of streams
      # then redirect them to 'fetch' action
    #
    
    # Display the list of streams
    streams = RadioStream.all
    dialog = Dialog.new(
      'type' => 'menu',
      'title' => 'Live Radio Streams',
      'items' => streams.map {|s| {'title' => s.title} }
    )
    respond_to do |format|
      format.dlg { render :text => dialog.to_yaml }
      format.html { render :text => dialog.to_html }
    end
  end
  
  def fetch
    RadioStream.fetch
    redirect('/streams')
  end
  
  def select
  
  end

end
