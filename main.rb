require_relative 'update'
require_relative 'psdatabase'

require 'json'
require 'sinatra'

# API web-server settings
set :port, 80

psdatabase = PSDatabase.new

get '/' do
  send_file 'web/index.html'
end

def get_updates(title_id)
  if title_id.split('-').length == 2
    title_code = title_id.split('-')[1]
    title_id = title_id.split('-').join if (title_code !~ /\D/) && (title_code.length == 5)
  end

  psn = Update.new(title_id)
  psn.updates
end

get '/:title_id' do
  content_type :json
  title_id = params[:title_id].to_s

  psquery = psdatabase.search title_id

  if psquery.nil?
    data = get_updates title_id
    psdatabase.save(title_id, data)
    return data.to_json
  else
    psquery.to_json
  end
end

get '/:title_id/newest' do
  content_type :json
  title_id = params[:title_id].to_s

  psquery = psdatabase.search title_id

  if psquery.nil?
    data = get_updates title_id
    psdatabase.save(title_id, data)
    data[:updates] = data[:updates].last if data[:title] != ''
    return data.to_json
  else
    psquery[:updates] = psquery[:updates].last if psquery[:title] != ''
    psquery.to_json
  end
end

get '/*/*' do
  status 404
  send_file 'web/api_error.html'
end
