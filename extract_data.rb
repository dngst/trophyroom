require 'csv'
require 'musicbrainz'

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
    "MBID for album '#{album_name}': #{release_group[:id]}"
  else
    "No MBID found for album '#{album_name}' by #{artist}"
  end
end

csv_file_path = 'albums.csv'

CSV.foreach(csv_file_path, headers: true) do |row|
  artist = row['Artist']
  album_name = row['Album']
  puts find_album_mbid(artist, album_name)
end

