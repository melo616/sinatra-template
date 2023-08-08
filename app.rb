require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

ebird_key = ENV.fetch("EBIRD_KEY")
nuthatch_key = ENV.fetch("NUTHATCH_KEY")

get("/") do
  nuthatch_url = "https://nuthatch.lastelm.software/v2/birds?page=1&pageSize=50&hasImg=true&operator=AND"

  request_headers_hash = {
    "api-key" => "#{nuthatch_key}" 
  }
  raw_response = HTTP.get(nuthatch_url, headers: request_headers_hash).to_s
  parsed_response = JSON.parse(raw_response)
  random_bird_index = rand(0..49)
  @random_bird = parsed_response.fetch("entities").at(random_bird_index)
  random_bird_image_index = rand(0..(@random_bird.fetch("images").length-1))
  @random_bird_image_src = @random_bird.fetch("images").at(random_bird_image_index)
  erb(:homepage)
end

get("/nearby_birds") do
  @user_location = params.fetch("user_location")
  user_location = @user_location.gsub(" ", "%20")
  maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")
  response = HTTP.get(maps_url).to_s
  parsed_response = JSON.parse(response)
  if parsed_response.fetch("results") == []
    @nearby_birds_array = []
  else
    results = parsed_response.fetch("results").at(0).fetch("geometry").fetch("location")
    lat = results.fetch("lat").to_s
    lng = results.fetch("lng").to_s

    ebird_url = "https://api.ebird.org/v2/data/obs/geo/recent?lat=" + lat + "&lng=" + lng + "&key=" + ebird_key
    response = HTTP.get(ebird_url).to_s
    @nearby_birds_array = JSON.parse(response)
  end
  erb(:birdsnearby)
end
