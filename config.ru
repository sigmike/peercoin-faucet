# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if (canonical_host = FaucetConfig["canonical_host"]).present?
  use Rack::CanonicalHost, canonical_host 
end

run Rails.application
