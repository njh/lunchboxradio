class Application < Merb::Controller

  protected
  
  def formatted_url(name, *args)
    url(name, :format => params['format'], *args)
  end
  
end
