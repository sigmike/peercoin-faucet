class MainController < ApplicationController
  def index
    @coin_request = CoinRequest.new
    @coin_request.attributes = params[:coin_request].permit(:address) if params[:coin_request]
    if request.post? or request.put?
      return unless verify_recaptcha(model: @coin_request)

      ip = request.remote_ip

      # Ensure the client can actually receive data at this IP
      # (session cookie is signed, so it cannot be forged)
      raise "Invalid IP" unless session[:ip] == ip

      uniqueness_data = [Date.today, ip].to_yaml
      @coin_request.uniqueness_token = Digest::SHA1.hexdigest(uniqueness_data)

      if @coin_request.save
        redirect_to root_path, flash: {notice: 'Request created'}
      end
    end
    session[:ip] = request.remote_ip
  end
end
