require 'sqlite3'

# Save PSN game updates in a SQLite3 database
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

  def flush_buffer
    flush = @buffer
    @buffer = { title_id: nil, title: nil, updates: [] }
    return flush
  end

  def registered?(title_id)
    @database.get_first_value('SELECT COUNT(*) FROM games WHERE title_id = ?', title_id).to_i == 1
  end

  def search(title_id)
    return nil unless registered? title_id

    game = @database.query 'SELECT * FROM games WHERE title_id = ?', title_id
    game = game.next

    @buffer[:title_id] = game['title_id']
    @buffer[:title] = game['title']

    if game['has_update'].to_i == 1
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

    return flush_buffer
  end

  def save(title_id, data)
    return if (registered? title_id) || data[:title] == ''

    puts data[:updates]
    @database.execute "INSERT INTO games VALUES ('#{title_id}', '#{data[:title]}', #{data[:updates].empty? ? '0' : '1'})"

    return if data[:updates].empty?

    data[:updates].each do |update|
      @database.execute "INSERT INTO updates VALUES ('#{update[:sha1]}', '#{update[:url]}', #{update[:version]}, #{update[:min_firmware]}, #{update[:size_mb]}, '#{title_id}')"
    end
  end
end