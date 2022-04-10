require_relative 'update'
require 'json'
require 'sinatra'

# API web-server settings
set :port, 80

get '/' do
  send_file 'web/index.html'
end

def get_updates(title_id)
  if title_id.split('-').length == 2
    title_code = title_id.split('-')[1]
    title_id = title_id.split('-').join if (title_code !~ /\D/) && (title_code.length == 5)
  end

  psn = Update.new(title_id)
  psn.json_updates
end

get '/:title_id' do
  content_type :json
  title_id = params[:title_id].to_s

  get_updates title_id
end

get '/:title_id/newest' do
  content_type :json
  title_id = params[:title_id].to_s

  update = JSON.parse get_updates(title_id)
  update['updates'] = update['updates'].last if update['title'] != ''

  update.to_json
end

get '/*/*' do
  status 404
  send_file 'web/api_error.html'
end
