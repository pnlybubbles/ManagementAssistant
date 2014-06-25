require_relative "./accessor.rb"

class SpeechRecognition
  def initialize
    @accessor = Accessor::Socket.new
    @on_response_block = nil
    @on_open_block = nil
    @on_close_block = nil
  end

  def response(&block)
    @on_response_block = block
  end

  def open(&block)
    @on_open_block = block
  end

  def close(&block)
    @on_close_block = block
  end

  def start
    on_open_block = @on_open_block
    on_response_block = @on_response_block
    on_close_block = @on_close_block
    @accessor.script do
      event("open") {
        on_open_block.call if on_open_block
      }
      event("load") {
        call_function("start_speech_recognition")
      }
      event("result") { |str|
        on_response_block.call(str.strip) if on_response_block
      }
      event("close") {
        on_close_block.call if on_close_block
      }
    end
    @accessor.start
  end
end