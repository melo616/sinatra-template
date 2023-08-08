require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

ebird_key = ENV.fetch("EBIRD_KEY")
gmaps_key = ENV.fetch("GMAPS_KEY")

get("/") do
  erb(:homepage)
end

get("/nearby_birds") do
  @user_location = params.fetch("user_location")
  user_location = @user_location.gsub(" ", "%20")
  maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")
  response = HTTP.get(maps_url).to_s
  parsed_response = JSON.parse(response)
  results = parsed_response.fetch("results").at(0).fetch("geometry").fetch("location")
  lat = results.fetch("lat").to_s
  lng = results.fetch("lng").to_s

  ebird_url = "https://api.ebird.org/v2/data/obs/geo/recent?lat=" + lat + "&lng=" + lng + "&key=" + ebird_key
  response = HTTP.get(ebird_url).to_s
  @nearby_birds_array = JSON.parse(response)
  erb(:birdsnearby)
end
