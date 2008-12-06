class PagesController < ApplicationController

  def index
    # FIXME: would rather this was in a template
    dialog = Dialog.new(
      'type' => 'menu',
      'title' => 'Main Menu',
      'items' => [
        {'title' => 'Live Radio', 'href' => streams_url},
        {'title' => 'About This Radio', 'href' => about_url},
        {'title' => 'Exit', 'href' => 'ruby:exit'},
      ]
    )
    respond_to do |format|
      format.dlg { render :text => dialog.to_yaml }
      format.html { render :text => dialog.to_html }
    end
  end

  def about
    # FIXME: would rather this was in a template
    dialog = Dialog.new(
      'type' => 'msgbox',
      'title' => 'About This Radio',
      'text' => 'Nicholas Humfrey made this radio.'
    )
    respond_to do |format|
      format.dlg { render :text => dialog.to_yaml }
      format.html { render :text => dialog.to_html }
    end
  end

end
