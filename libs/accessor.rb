require "em-websocket"
require "json"

module Accessor
  class Socket
    def initialize(debug = false)
      @tr = nil
      @script = nil
      @debug = debug
    end

    def start
      EM::WebSocket.start(:host => "localhost", :port => 8080, :debug => @debug) do |ws|
        ws.onopen {
          @tr = Transfer.new(ws)
          @tr.instance_eval(&@script)
          @tr.send("evt_open", nil)
        }

        ws.onmessage { |msg|
          @tr.get(JSON.parse(msg))
        }

        ws.onclose {
          @tr.send("evt_close", nil)
        }
      end
    end

    def script(&blk)
      @script = blk
    end
  end

  class Transfer
    def initialize(ws)
      @ws = ws
      @callback_queue = {}
    end

    def send_ws(msg)
      msg["from"] = "server"
      # pp msg
      @ws.send(JSON.generate(msg).to_s)
    end

    def tell(req, *callback)
      callback_id = nil
      if !callback.empty? && callback[0]
        callback_id = rand(36**4).to_s(36)
        @callback_queue[callback_id] = Queue.new
      end
      msg = {"type" => "event", "content" => req, "callback_id" => callback_id}
      send_ws(msg)
      return @callback_queue[callback_id] if callback_id
    end

    def get(req)
      Thread.new {
        begin
          if req["from"] == "client"
            # pp req
            e = req["content"]
            case req["type"]
            when "event"
              argu = e["argu"].nil? ? [] : (e["argu"].class == Array ? e["argu"] : [e["argu"]])
              ret = self.send("evt_#{e['name']}", *argu)
              if req["callback_id"]
                msg = {"type" => "callback", "content" => {"return" => ret}, "callback_id" => req["callback_id"]}
                send_ws(msg)
              end
            when "callback"
              @callback_queue[req["callback_id"]].push(e["return"])
            end
          end
        rescue Exception => e
          puts e
          puts e.backtrace
        end
      }
    end

    def event(event_name)
      raise "Error: no block given." unless block_given?
      self.class.class_eval do
        define_method("evt_#{event_name}") { |*argu|
          yield(*argu)
        }
      end
    end

    def call_function(func_name, *argu)
      argu = argu.nil? ? [] : (argu.class == Array ? argu : [argu])
      msg = {"name" => func_name, "argu" => argu}
      return tell(msg, true).pop
    end

    def call_function_asynchronous(func_name, *argu)
      argu = argu.nil? ? [] : (argu.class == Array ? argu : [argu])
      msg = {"name" => func_name, "argu" => argu}
      tell(msg)
    end

    def method_missing(meth, *args, &blk)
      puts "method_missing : #{meth}"
    end
  end
end
