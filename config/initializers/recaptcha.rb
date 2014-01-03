Recaptcha.configure do |config|
  config.public_key  = CONFIG["recaptcha"]["public_key"]
  config.private_key = CONFIG["recaptcha"]["private_key"]
end
