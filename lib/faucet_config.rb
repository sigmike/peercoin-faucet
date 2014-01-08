
path = File.expand_path('../../config/config.yml', __FILE__)
FaucetConfig = YAML.load(File.read(path))

def FaucetConfig.parse_time(time)
  amount, unit = time.split
  amount = amount.to_f
  case unit
  when nil, "second", "seconds"
  when "minute", "minutes"
    amount *= 60
  when "hour", "hours"
    amount *= 3600
  when "day", "days"
    amount *= 24 * 3600
  when "week", "weeks"
    amount *= 7 * 24 * 3600
  when "month", "months"
    amount *= 30 * 24 * 3600
  when "year", "years"
    amount *= 365 * 24 * 3600
  else
    raise "Invalid time unit: #{unit.inspect}"
  end
  amount.floor
end

def FaucetConfig.request_time_frame_duration
  parse_time(self["request_time_frame_duration"])
end

def FaucetConfig.time_between_request_fulfilling
  if time = self["time_between_request_fulfilling"]
    parse_time(time)
  else
    request_time_frame_duration
  end
end
