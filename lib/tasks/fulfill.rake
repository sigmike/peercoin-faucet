task :fulfill => :environment do
  CoinRequest.fulfill!
end
