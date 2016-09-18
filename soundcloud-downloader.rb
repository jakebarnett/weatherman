require "faraday"
require "JSON"
require "nokogiri"

link = ARGV.first.split('.com')[1]

# get user id without having to use the api
get_userid_connection = Faraday.new(:url => "https://soundcloud.com") do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

get_userid_response = get_userid_connection.get "#{link}"
user_id_html_doc = Nokogiri::HTML(get_userid_response.body)
user_id = user_id_html_doc.at('meta[property="twitter:app:url:googleplay"]')['content'].split(':').last

puts "Collecting songs"

# page through the liked songs and collect the urls to download
conn = Faraday.new(:url => "https://api-v2.soundcloud.com") do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

raw_response = conn.get "/users/#{user_id}/likes?client_id=02gUJC0hH2ct1EGOcYXQIzRFU91c72Ea&limit=24&offset=0&linked_partitioning=1&app_version=1473616168"
json_response = JSON.parse(raw_response.body)

download_urls = []
to_download_count = 0
download_urls << json_response['collection'].map { |c| c['track'] }.compact.map { |c| c['permalink_url']}
offset = CGI::parse(json_response["next_href"].split('?')[1])["offset"][0]

while offset
  raw_response = conn.get "/users/#{user_id}/likes?client_id=02gUJC0hH2ct1EGOcYXQIzRFU91c72Ea&limit=24&offset=#{offset}&linked_partitioning=1&app_version=1473616168"
  json_response = JSON.parse(raw_response.body)
  found_on_page =  json_response['collection'].map { |c| c['track'] }.compact.map { |c| c['permalink_url']}
  download_urls << found_on_page
  
  to_download_count += found_on_page.count
  puts "found #{to_download_count} songs..."
  
  offset = json_response["next_href"] ? CGI::parse(json_response["next_href"].split('?')[1])["offset"][0] : nil
end

# dowload the list
puts "found #{download_urls.flatten.count} songs to download"
puts "would you like to download all #{download_urls.flatten.count} songs? (enter yes or no)"
confirm = STDIN.gets.chomp
exit unless confirm =  ("y" || "yes")
download_urls.flatten.each { |url| system "youtube-dl #{url}" }
