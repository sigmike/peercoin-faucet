class MainController < ApplicationController
  def index
    @coin_request = CoinRequest.new
    @coin_request.attributes = params[:coin_request].permit(:address) if params[:coin_request]
    if request.post? or request.put?
      if CONFIG["captcha"]
        return unless verify_recaptcha(model: @coin_request)
      end

      ip = request.remote_ip

      # Ensure the client can actually receive data at this IP
      # (session cookie is signed, so it cannot be forged)
      raise "Invalid IP" unless session[:ip] == ip

      time_frame = (Time.now.to_i / parse_time(CONFIG["request_time_frame_duration"])).floor

      uniqueness_data = [time_frame, ip].to_yaml
      @coin_request.uniqueness_token = Digest::SHA1.hexdigest(uniqueness_data)

      if @coin_request.save
        redirect_to root_path, flash: {notice: 'Request created'}
      end
    end
    session[:ip] = request.remote_ip
  end

  protected
  def parse_time(time)
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
    else
      raise "Invalid time unit: #{unit.inspect}"
    end
    amount
  end
end
