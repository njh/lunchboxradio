class StreamsController < ApplicationController

  def index
    latest_stream = RadioStream.first(:order => 'updated_at DESC')
    if latest_stream.nil? or latest_stream.updated_at < DateTime.now.beginning_of_day
      # Tell user that we need to fetch a list of streams
      render_dialog(
        'type' => 'infobox',
        'title' => 'Updating Live Radio Streams',
        'text' => "Please wait while the list of live streams is updated...",
        'redirect' => fetch_streams_url
      )
    else
      # Display the list of streams
      streams = RadioStream.all
      render_dialog(
        'type' => 'menu',
        'title' => 'Live Radio Streams',
        'items' => streams.map {|s| {'title' => s.title} }
      )
    end
  end
  
  def fetch
    # FIXME: catch exceptions and inform user
    RadioStream.fetch
    redirect_to streams_url
  end
  
  def select
  
  end

end
