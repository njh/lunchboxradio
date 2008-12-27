# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Log to directory on tmpfs
config.logger = Logger.new('/var/giggi/log/production.log', 1, 1024000)
config.log_level = :info

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Cache to directory on tmpfs
config.cache_store = :file_store, '/var/giggi/cache'
