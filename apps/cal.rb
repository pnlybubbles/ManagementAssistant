# encoding: utf-8

App.create(:cal, ["カレンダー"]) do
  def init(input, match_data)
    @local_commands = {:show => ["表示"]}
  end

  def speech(text)
    
  end

  def show(input, match_data)
    cal = `cal`
    puts cal.to_s
    output = {:string => cal.to_s, :default => cal.to_s}
    return output
  end
end