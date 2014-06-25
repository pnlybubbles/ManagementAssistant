require 'webrick'
require 'webrick/https'

server = WEBrick::HTTPServer.new({
  :DocumentRoot => "./",
  :BindAddress => '0.0.0.0',
  :Port => 10080,
  :SSLEnable  => true,
  :SSLCertName  => [ [ 'CN', WEBrick::Utils::getservername ] ]
})

['INT', 'TERM'].each {|signal|
  Signal.trap(signal){ server.shutdown }
}

server.start
