require 'sqlite3'

class PSDatabase
  def initialize
    @database = SQLite3::Database.open 'database/psdb.sqlite'
    @database.results_as_hash = true
    if File.exist? 'database/init.sql'
      File.read('database/init.sql').split(';').each do |query|
        @database.execute query
      end
    end
    @buffer = { title_id: nil, title: nil, updates: [] }
  end

  def search(title_id)
    count = @database.get_first_value 'SELECT COUNT(*) FROM games WHERE title_id = ?', title_id
    return nil if count.to_i != 1

    game = @database.query 'SELECT * FROM games WHERE title_id = ?', title_id
    game = game.next

    @buffer[:title_id] = game['title_id']
    @buffer[:title] = game['title']

    updates = @database.execute 'SELECT * FROM updates WHERE title_id = ?', title_id
    updates.each do |update|
      @buffer[:updates] += [
        version: update['version'].to_f,
        min_firmware: update['min_firmware'].to_f,
        size_mb: update['size_mb'].to_f,
        url: update['url'],
        sha1: update['sha1']
      ]
    end
  end
end