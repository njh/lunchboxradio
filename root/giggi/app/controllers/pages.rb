class Pages < Application
  provides :html, :dlg
  
  def index
    # FIXME: would rather this was in a template
    dialog = Dialog.new(
      'type' => 'menu',
      'title' => 'Main Menu',
      'items' => [
        {'title' => 'Live Radio', 'href' => formatted_url(:streams)},
        {'title' => 'About This Radio', 'href' => formatted_url(:about)},
        {'title' => 'Exit', 'href' => 'ruby:exit'},
      ]
    )
    display dialog, :layout => "application"
  end

  def about
    # FIXME: would rather this was in a template
    dialog = Dialog.new(
      'type' => 'msgbox',
      'title' => 'About This Radio',
      'text' => 'Nicholas Humfrey made this radio.'
    )
    display dialog, :layout => "application"
  end

end
