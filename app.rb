class App
  @@global_commands = {} # {global_id => [command, ...]}
  @@apps = {} # {global_id => Proc}
  @@output = {:default => nil}

  def self.create(global_id, global_command, &blk)
    @@global_commands[global_id.to_sym] = global_command
    @@apps[global_id.to_sym] = blk
    # p @@global_commands
    # p @@apps
  end

  def self.global_commands
    return @@global_commands
  end

  def self.output
    return @@output
  end

  attr_reader :local_commands, :global_id

  def initialize(global_id)
    @global_id = global_id
    @local_commands = {}
    @command_propagation = true
    # p @global_id
    # p @@apps[@global_id]
    self.instance_eval(&@@apps[global_id])
  end

  def speech_command_analyze(text)
    @command_propagation = true
    speech(text)
    matched_commands = []
    if @command_propagation
      type = :local
      @local_commands.each { |id, commands|
        commands.each { |command|
          match_data = text.match(command.class == Regexp ? command : Regexp.new(command.gsub(/\s+/, ".*")))
          if match_data
            matched_commands << {:type => type, :id => id, :match_data => match_data}
          end
        }
      }
    end
    unless matched_commands.empty?
      @@output = send(matched_commands[0][:id], @@output, matched_commands[0][:match_data])
      @command_propagation = false
    end
    return @command_propagation
  end
end