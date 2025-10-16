import Config

# Suppress Tesla deprecation warning
config :tesla, disable_deprecated_builder_warning: true

# Configure Tesla mock adapter for test environment
if config_env() == :test do
  config :tesla, adapter: Tesla.Mock
end
