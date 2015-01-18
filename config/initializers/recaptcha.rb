Recaptcha.configure do |config|
  config.public_key  = FaucetConfig["recaptcha"]["public_key"]
  config.private_key = FaucetConfig["recaptcha"]["private_key"]
  config.api_version = 'v2'
end
