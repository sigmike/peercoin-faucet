# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :reboot do
  command File.expand_path("../../../ppcoin/src/ppcoind", __FILE__)
  rake "update_state:loop"
end

require File.expand_path('../../lib/faucet_config', __FILE__)
frame_time = FaucetConfig.request_time_frame_duration.seconds
every frame_time do
  rake "fulfill"
end

