require 'csv'
require 'json'
require 'musicbrainz'
require 'httparty'

MusicBrainz.configure do |c|
  # Application identity (required)
  c.app_name = "trophyroom"
  c.app_version = "1.0"
  c.contact = "eddieatsenga@protonmail.com"
end

def find_album_mbid(artist, album_name)
  results = MusicBrainz::ReleaseGroup.search(artist, album_name, 'Album')
  release_group = results.first

  if release_group
    release_group[:id]
  end
end

def get_cover_art(mbid)
  response = HTTParty.get("https://coverartarchive.org/release-group/#{mbid}")
  response.parsed_response['images'].first['image'] if response.parsed_response['images']
end

csv_file_path = 'albums.csv'
album_data = []

CSV.foreach(csv_file_path, headers: true) do |row|
  artist = row['Artist']
  album_name = row['Album']
  mbid = find_album_mbid(artist, album_name)
  cover_art_url = get_cover_art(mbid)

  if cover_art_url
    album_data << {
      "artist" => artist,
      "album" => album_name,
      "image" => cover_art_url
    }
  end
end

File.open("album_covers.json", "w") do |file|
  file.write(JSON.pretty_generate(album_data))
end

puts "Done."

