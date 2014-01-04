require 'open3'

module Peercoin
  module_function

  class RPCError < StandardError
    attr_accessor :command
    attr_accessor :code
  end

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
      begin
        detail = JSON.parse(err.sub(/\Aerror: /, ''))
      rescue
        raise "#{cmd.inspect}: #{err}"
      end
      error = RPCError.new(detail["message"])
      error.code = detail["code"]
      error.command = cmd
      raise error
    else
      out.strip
    end
  end

  def address_valid?(address)
    JSON.parse(run("validateaddress", address))["isvalid"]
  end

  def account
    FaucetConfig["ppcoind_account"] || ""
  end

  def minimum_confirmations
    FaucetConfig["minimum_confirmations"] || 1
  end
  alias_method :minconf, :minimum_confirmations

  def address
    run(:getaccountaddress, account)
  end

  def balance
    run(:getbalance, account, minimum_confirmations).to_f
  end

  class InsufficientFunds < StandardError
  end

  def send_many(recipients)
    command = [
      :sendmany,
      account,
      recipients.to_json,
    ]
    command << minimum_confirmations
    begin
      run(*command)
    rescue RPCError => e
      if e.code == -6
        raise InsufficientFunds.new(e.message)
      else
        raise e
      end
    end
  end

  def transactions
    JSON.parse(run(:listtransactions))
  end
end
