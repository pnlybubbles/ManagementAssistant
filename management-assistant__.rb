# encoding: utf-8

require_relative "./libs/accessor.rb"

class SpeechRecognition
  def initialize(&block)
    @accessor = Accessor::Socket.new
    setup_accessor_event(block)
    @accessor.start
  end

  private
  def setup_accessor_event(block)
    @accessor.script do
      event("open") {
        puts "opened"
      }
      event("load") {
        call_function("start_speech_recognition")
      }
      event("result") { |str|
        block.call(str.strip)
      }
      event("close") {
        puts "closed"
      }
    end
  end
end

class Core
  def initialize
    @magazins = Magazin.magazins
    @phrases = Magazins.map { |m| m.phrase }
    @input = nil
  end

  def interpret_speech(speech)
    combined_phrases = speech
    split_phrases = []
    split_phrases_type = []

    loop {
      index = nil
      matched_phrase = nil

      catch(:phrases) {
        @phrases.each_with_index { |phrases_arr, i|
          phrases_arr.each_with_index { |phrase, j|
            matched_phrase = combined_phrases.match(/#{phrase}/)
            if matched_phrase
              index = i
              matched_phrase = matched_phrase.to_s
              throw(:phrases)
            end
          }
        }
      }

      if index
        combined_phrases = combined_phrases.gsub(/^#{matched_phrase}\s*/, "").to_s
        if combined_phrases.empty?
          break
        end
      end
    }

    @magazins[index].init(input)
  end

  def run
    SpeechRecognition.new { |res|
      puts res
    }
  end
end

class Magazin
  @@ids = []
  @@magazins = []

  attr_reader :id, :phrase

  def initialize(id, phrase, block)
    @id = id
    @phrase = phrase
    add_magazin()
    self.instance_eval(block)
  end

  def self.create(id, phrase, &block)
    if @@ids.index(id)
      @@ids << id.to_sym
      return self.new(id, phrase, block)
    end
  end

  def self.magazins
    return @@magazins
  end

  def add_magazin
    @@magazins << self
  end
end

Magazin.create(:timenow, ["現在時刻"]) {
  def init(input, param)
    @time = nil
    @region = input || param
    refresh()
    show_time()
  end

  def default_return
    return @time.strftime("%H時%M分%S秒")
  end

  private
  def show_time
    puts @time.strftime("%H時%M分%S秒")
  end

  def refresh
    @time = Time.now
  end
}

Magazin.create(:speech, ["読み上げ"]) {
  def init(input, param)
    @speech = input || param
    speech()
  end

  def default_return
    return @speech
  end

  private
  def speech
    puts @speech
  end
}

Core.new.run
