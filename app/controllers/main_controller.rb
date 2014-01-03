class MainController < ApplicationController
  def index
    @coin_request = CoinRequest.new
    @coin_request.attributes = params[:coin_request].permit(:address) if params[:coin_request]
    @coin_request.ip = request.remote_ip
    if request.post? or request.put?

      # Ensure the client can actually receive data at this IP
      # (session cookie is signed, so it cannot be forged)
      raise "Invalid IP" unless session[:ip] == @coin_request.ip

      if @coin_request.save
        redirect_to root_path, flash: {notice: 'Request created'}
      end
    end
    session[:ip] = request.remote_ip
  end
end
