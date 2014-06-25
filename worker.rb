# encoding: utf-8

require_relative "./core_app.rb"

Dir.glob("./apps/*") { |file|
  require_relative file
}

CoreApp.new.run
