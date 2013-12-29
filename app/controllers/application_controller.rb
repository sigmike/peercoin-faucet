class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  def ppcoind(command, *args)
    require 'open3'
    cmd = []
    cmd << Rails.application.config.ppcoind
    cmd << command.to_s
    cmd += args
    cmd.map!(&:to_s)
    out, err, status = Open3.capture3(*cmd)
    if status != 0
      raise "#{args.inspect}: #{err}"
    else
      out.strip
    end
  end
  helper_method :ppcoind
end
