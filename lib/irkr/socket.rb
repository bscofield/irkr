require 'socket'

module Irkr
  class Socket
    attr_accessor :tcp_socket, :session_live

    def initialize(server, port, nick, password = nil)
      @server, @port, @nick, @password = server, port, nick, password

      @handlers        = {}
      @joined_channels = {}
      @to_join         = []

      define_standard_handlers
    end
    
    def channels
      @joined_channels
    end

    def connected?
      self.tcp_socket.nil?
    end
    
    def connect
      self.tcp_socket = TCPSocket.new(@server, @port)
      
      send_raw("USER #{@nick} #{@nick} #{@nick} #{@nick}")
      send_raw("NICK #{@nick}")
      send_raw("NickServ IDENTIFY #{@password}") if @password

      # TODO: handle errors back from this IDENTIFY 
      # TODO: auto-REGISTER if need be
      
      self.session_live = true
      join(@to_join) unless @to_join.empty?
      
      begin
        while line = self.tcp_socket.gets
          handle_incoming_line(line) 
        end
      rescue IOError => ioe
        raise ioe if self.session_live
      end
    end
    
    def quit
      send_raw('QUIT: Time to go')
      self.session_live = false
      self.tcp_socket.close
    end

    def join(join_channels)
      join_channels = [join_channels] if join_channels.is_a?(String)
      if self.session_live
        send_raw("JOIN #{join_channels * ', '}")
      else
        @to_join = join_channels
      end
    end
    
    def tell(name, message)
      send_raw("PRIVMSG #{name} #{message}")
    end
    
    def command(message)
      send_raw(message)
    end

    def handle(expression = nil, &block)
      unless expression
        @handlers[block] = /./
      else
        if expression.is_a?(Regexp)
          @handlers[block] = expression
        else
          pattern = %r{^\:(\S+) (#{expression.to_s}) (\S+) \:(.+)}
          @handlers[block] = pattern
        end
      end
    end
    
    def method_missing(name, *args)
      send_raw("#{name.to_s.upcase} #{args * ' '}")
    end
    
    private
    def send_raw(message)
      self.tcp_socket.puts(message)
    end
    
    def handle_incoming_line(line)
      @handlers.each do |block, pattern|
        match = pattern.match(line)
        next if match.nil?
        
        block.call Irkr::Message.new(line, pattern, match)
      end
    end
    
    def define_standard_handlers
      handle { |event|
        puts "#{event.line}"
      }

      # handle PINGS
      handle(/^PING /) { |event|
        send_raw("PING #{event.match.post_match}")
      }

      # handle channel JOINs
      handle(/ JOIN \:(#.+)/) { |event|
        name = event.match[1].chomp.strip
        @joined_channels[name] = Irkr::Channel.new(name) unless @joined_channels[name]
      }

      # handle channel redirect after JOIN
      # TODO: notify client of redirect
      handle(/ 470 .+? (#.+?) (#.+?) :/) { |event|
        send_raw("PART #{event.match[2]}")
      }

      # handle channel PART
      handle('PART') { |event|
        @joined_channels.delete(event.match[3])
      }

      # handle server-sent topic
      handle(/ 332 .+? (#.+?) :(.+)/) { |event|
        name = event.match[1]
        @joined_channels[name].topic = event.match[2] if @joined_channels[name]
      }
    end
  end
end