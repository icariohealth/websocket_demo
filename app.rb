require 'thin'
require 'sinatra/base'
require 'em-websocket'

EventMachine.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end


  @clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      @clients << ws
      ws.send "#{Time.zone.now.to_s(:db)} - Connected to #{handshake.path}."
    end

    ws.onclose do
      ws.send "#{Time.zone.now.to_s(:db)} - Closed."
      @clients.delete ws
    end

    ws.onmessage do |msg|
      puts "#{Time.zone.now.to_s(:db)} - Received Message: #{msg}"
      @clients.each do |socket|
        socket.send msg
      end
    end
  end


  App.run! :port => 3002
end
