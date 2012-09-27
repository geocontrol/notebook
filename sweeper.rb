require 'rubygems'
require 'sinatra'
require 'twitter'

get '/' do
  erb :sweep_form
end

post '/form' do
  search = Twitter.search("#iampossible").results.map do |status|
    "<p>#{status.from_user}: #{status.text}"
  end
  return search
end
