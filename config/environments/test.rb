require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here take precedence over those in config/application.rb.

  # Enable caching in the test environment
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  # While tests run, files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, but it's recommended in CI.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports and enable caching.
  config.consider_all_requests_local = true

  # Note: Removed these lines that disable caching:
  # config.action_controller.perform_caching = false
  # config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for others.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Disable caching for Action Mailer templates even if Action Controller caching is enabled.
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "www.example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Uncomment to raise error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Uncomment to annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true
end
