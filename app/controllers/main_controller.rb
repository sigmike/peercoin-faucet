class MainController < ApplicationController
  def index
    @coin_request = CoinRequest.new
    @coin_request.attributes = params[:coin_request].permit(:address) if params[:coin_request]
    if request.post? or request.put?
      if @coin_request.save
        redirect_to root_path, flash: {notice: 'Request created'}
      end
    end
  end
end
