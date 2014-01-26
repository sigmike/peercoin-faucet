class MainController < ApplicationController
  BLOCKED_DNSBL = YAML.load(Rails.root.join("config/blocked_dnsbl.yaml").read)

  before_filter :get_state

  def index
    @coin_request = CoinRequest.new
    @coin_request.attributes = params[:coin_request].permit(:address) if params[:coin_request]
    if request.post? or request.put?
      if FaucetConfig["captcha"]
        unless verify_recaptcha(model: @coin_request)
          flash.delete(:recaptcha_error)
          return
        end
      end

      ip = request.remote_ip

      dnsbl= DNSBL::Client.new
      matches = dnsbl.lookup(ip)
      matches.select! do |match|
        blocked_results = BLOCKED_DNSBL[match.dnsbl]
        blocked_results and blocked_results.has_key?(match.result)
      end
      if matches.any?
        message = "Your IP is blacklisted for the following reason(s): " + matches.map { |match| "#{match.meaning} (#{match.dnsbl})" }.join(", ")
        redirect_to root_path, flash: {error: message}
        return
      end

      # Ensure the client can actually receive data at this IP
      # (session cookie is signed, so it cannot be forged)
      raise "Invalid IP" unless session[:ip] == ip

      frame_duration = FaucetConfig.request_time_frame_duration
      time_frame = (Time.now.to_i / frame_duration).floor * frame_duration

      uniqueness_data = [time_frame, ip].to_yaml
      @coin_request.uniqueness_token = Digest::SHA1.hexdigest(uniqueness_data)

      if @coin_request.save
        redirect_to root_path, flash: {success: 'You request was created. It will be processed in the next batch or when enough funds are available'}
      end
    end
    session[:ip] = request.remote_ip
  end

  protected
  def get_state
    @state = State.instance
    @currency = FaucetConfig["currency"] || (@state.testnet? ? "testnet peercoin" : "peercoin")
  end
end
