require "socket"
require "./memory"

module BoJack
  module Server
    def self.start(hostname = "127.0.0.1", port = 5000)
      server = TCPServer.new(hostname, port)
      server.recv_buffer_size = 4096
      memory = BoJack::Memory(String, String).new

      loop do
        socket = server.accept
        if socket
          spawn do
            loop do
              if request = socket.gets
                request = request.split(" ").map{|item| item.strip }
                command = request[0]

                if command == "ping"
                  socket.puts("pong")
                elsif command == "set"
                  key = request[1]
                  value = request[2]

                  memory.write(key, value)

                  socket.puts(value)
                elsif command == "get"
                  key = request[1]

                  begin
                    value = memory.read(key)
                    socket.puts(value)
                  rescue
                    socket.puts("error: '#{key}' is not a valid key")
                  end
                elsif command == "delete"
                  key = request[1]

                  begin
                    value = memory.delete(key)
                    socket.puts(value)
                  rescue
                    socket.puts("error: '#{key}' is not a valid key")
                  end
                elsif command == "size"
                  socket.puts(memory.size)
                elsif command == "close"
                  socket.puts("closing...")

                  socket.close
                  break
                else
                  socket.puts("error: '#{command}' is not a valid command")
                end
              end
            end
          end
        end
      end
    end
  end
end
