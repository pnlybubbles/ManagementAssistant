require_relative "./libs/speech_recognition.rb"
require_relative "./app.rb"

class CoreApp
  def initialize
    @foreground_app = nil
    @active_apps = {}
    @global_commands = App.global_commands
    @global_specific_commands = {}
    @speech_recognition = SpeechRecognition.new
    @speech_recognition.open {
      puts "Speech Recognition Opened"
      print "> "
    }
    @speech_recognition.close {
      puts "Closed"
    }
  end

  def speech_command_analyze(text)
    matched_commands = []
    available_commands = {
      :global => @global_commands,
      :specific => @global_specific_commands
    }
    available_commands.each { |type, commands_list|
      commands_list.each { |id, commands|
        commands.each { |command|
          match_data = text.match(command.class == Regexp ? command : Regexp.new(command.gsub(/\s+/, ".*")))
          if match_data
            matched_commands << {:type => type, :id => id, :match_data => match_data}
          end
        }
      }
    }
    # pp matched_commands
    unless matched_commands.empty?
      case matched_commands[0][:type]
      when :global
        app = App.new(matched_commands[0][:id])
        app.init(App.output, matched_commands[0][:match_data])
        @active_apps[app.global_id] = app unless @active_apps.key?(app.global_id)
        @foreground_app = app.global_id
      end
    end
  end

  def run
    @speech_recognition.response { |res|
      puts res
      command_propagation = true
      command_propagation = @active_apps[@foreground_app].speech_command_analyze(res.strip) if @foreground_app
      speech_command_analyze(res.strip) if command_propagation
      print "#{@foreground_app.to_s}> "
    }
    @speech_recognition.start
  end
end