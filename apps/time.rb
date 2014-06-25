# encoding: utf-8

App.create(:time, ["時計"]) do
  def init(input, match_data)
    @local_commands = {:show => ["表示"]}
  end

  def speech(text)
    
  end

  def show(input, match_data)
    time = Time.now
    puts time.to_s
    output = {:string => time.to_s, :time => time, :default => time.to_s}
    return output
  end
end
