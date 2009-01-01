ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  map.index 'index', :controller => 'pages', :action => 'index'
  map.formatted_index 'index.:format', :controller => 'pages', :action => 'index', :defaults => {:format => 'html'}
  map.about 'about', :controller => 'pages', :action => 'about'
  map.formatted_about 'about.:format', :controller => 'pages', :action => 'about', :defaults => {:format => 'html'}

  map.settings 'settings', :controller => 'pages', :action => 'settings'
  map.formatted_settings 'settings.:format', :controller => 'pages', :action => 'settings', :defaults => {:format => 'html'}
  
  map.resources :networks, :as => 'settings/networks'
  map.resources :streams

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "root"

  # See how all your routes lay out with "rake routes"
end
