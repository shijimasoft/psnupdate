require_relative 'update'
require 'sinatra'

# API web-server settings
set :port, 80

get '/' do
  send_file 'web/index.html'
end

get '/*/*' do
  status 404
  send_file 'web/api_error.html'
end

get '/:title_id' do
  content_type :json
  title_id = params[:title_id].to_s

  psn = Update.new(title_id)
  psn.json_updates
end
