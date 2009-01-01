class PagesController < ApplicationController

  def index
    render_dialog(
      'type' => 'menu',
      'title' => 'Main Menu',
      'items' => [
        {'title' => 'Live Radio', 'href' => streams_url},
        {'title' => 'About This Radio', 'href' => about_url},
        {'title' => 'Settings', 'href' => settings_url},
        {'title' => 'Exit', 'href' => 'ruby:exit'},
      ]
    )
  end

  def about
    render_dialog(
      'type' => 'msgbox',
      'title' => 'About This Radio',
      'text' => 'Nicholas Humfrey made this radio.'
    )
  end

  def settings
    render_dialog(
      'type' => 'menu',
      'title' => 'Settings',
      'items' => [
        {'title' => 'Network Settings', 'href' => networks_url},
      ]
    )
  end

end
