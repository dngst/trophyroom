require 'csv'
require 'json'
require 'httparty'
require 'ruby-progressbar'

def find_album_mbid(artist, album_name)
  url = "https://musicbrainz.org/ws/2/release-group/?query=artist:#{URI.encode_www_form_component(artist)}%20AND%20release:#{URI.encode_www_form_component(album_name)}&fmt=json"
  response = HTTParty.get(url, headers: { 'User-Agent' => 'trophyroom/1.0 (eddieatsenga@protonmail.com)' })

  response['release-groups'].first['id']
end

def get_cover_art(mbid)
  response = HTTParty.get("https://coverartarchive.org/release-group/#{mbid}")
  response.parsed_response['images'] && response.parsed_response['images'].first['image']
end

csv_file_path = 'albums.csv'
json_file_path = 'album_covers.json'

album_data = File.exist?(json_file_path) ? JSON.parse(File.read(json_file_path)) : []

no_of_albums = CSV.foreach(csv_file_path, headers: true).count
progressbar = ProgressBar.create(title: "Fetching albums", total: no_of_albums,format: "%t: |%B| %p%%")

CSV.foreach(csv_file_path, headers: true) do |row|
  artist = row['Artist']
  album_name = row['Album']

  existing_album = album_data.find { |a| a['artist'] == artist && a['album'] == album_name }
  unless existing_album
    mbid = find_album_mbid(artist, album_name)
    cover_art_url = get_cover_art(mbid)

    cover_art_url && album_data << {
      "artist" => artist,
      "album" => album_name,
      "image" => cover_art_url
    }
  end

  progressbar.increment
end

File.open(json_file_path, "w") do |file|
  file.write(JSON.pretty_generate(album_data))
end

