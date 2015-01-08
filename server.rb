#!/usr/bin/env ruby

require 'sinatra'
require 'houston'
require 'json'

post '/push/:device_token.json' do |device_token|
  puts device_token

  request.body.rewind
  payload = JSON.parse(request.body.read)

  puts payload

  # Environment variables are automatically read, or can be overridden by any specified options. You can also
  # conveniently use `Houston::Client.development` or `Houston::Client.production`.
  APN = Houston::Client.development
  APN.certificate = File.read("./apns-dev-cert.pem")

  # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
  notification = Houston::Notification.new(device: device_token)

  # notification.alert = "Hello, World!"
  # notification.badge = 57
  # notification.sound = "sosumi.aiff"
  # notification.category = "INVITE_CATEGORY"
  # notification.content_available = true
  # notification.custom_data = {foo: "bar"}

  payload.each do |key, value|
    notification.send("#{key}=", value)
  end

  # And... sent! That's all it takes.
  APN.push(notification)

  if ! notification.error
    puts "Notification sent:"
    sended_payload = JSON.pretty_generate(notification.payload)
    puts sended_payload

    return sended_payload
  else
    return [500, "Error: #{notification.error}"]
  end
end
