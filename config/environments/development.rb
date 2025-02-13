require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Always enable caching in development.
  config.action_controller.perform_caching = true

  # Attempt to use Redis as the cache store. If Redis isn't available, fallback to memory_store.
  begin
    redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
    redis_client = Redis.new(url: redis_url)
    # Test the Redis connection; this will raise an exception if Redis is not available.
    redis_client.ping
    config.cache_store = :redis_cache_store, { url: redis_url, expires_in: 1.week }
    puts "Using Redis cache store at #{redis_url}"
  rescue StandardError => e
    puts "Redis unavailable (#{e.message}); falling back to memory store."
    config.cache_store = :memory_store
  end

  # Enable reloading in development.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Use local storage for uploaded files.
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Disable caching for Action Mailer templates.
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true
end
