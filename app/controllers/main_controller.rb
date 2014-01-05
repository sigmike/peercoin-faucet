class MainController < ApplicationController
  def index
    @state = State.instance

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
end
