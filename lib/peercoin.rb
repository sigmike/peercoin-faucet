require 'open3'

module Peercoin
  module_function

  def run(command, *args)
    cmd = []
    cmd << Rails.application.config.ppcoind
    cmd << command.to_s
    cmd += args
    cmd.map!(&:to_s)
    Rails.logger.info cmd.inspect
    out, err, status = Open3.capture3(*cmd)
    Rails.logger.info out if out.present?
    Rails.logger.info err if err.present?
    if status != 0
      raise "#{cmd.inspect}: #{err}"
    else
      out.strip
    end
  end

  def address_valid?(address)
    JSON.parse(run("validateaddress", address))["isvalid"]
  end
end
