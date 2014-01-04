task :update_state => :environment do
  State.update!
end

namespace :update_state do
  task :loop => :environment do
    loop do
      begin
        State.update!
      rescue => e
        logger = State.logger
        logger.error "Error while updating state:"
        logger.error "#{e.message} (#{e.class})"
        logger.error e.backtrace.join("\n")
      end
      sleep 30
    end
  end
end
