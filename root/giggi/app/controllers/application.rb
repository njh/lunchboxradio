# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c3f4c3184d94486a922965f88040bae1'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def render_dialog(dialog)
    # Convert to dialog if it isn't one already
    unless dialog.is_a? Dialog
      dialog = Dialog.new(dialog)
    end
    
    respond_to do |format|
      format.dlg {
        render :text => dialog.to_yaml
      }
      format.html {
        @page_title = dialog['title']
        render :text => dialog.to_html, :layout => "application"
      }
    end
  end
end
