# session = Irkr::Session.start('bscofield')
# session.join('#tester')
# session.connect
# session.tell('#tester', 'hello world!')
# session.command('NICK not_bscofield')
# session.quit
module Irkr
  class Session
    class << self
      attr_accessor :sockets, :server, :port
    end
    
    def initialize
      raise RuntimeError, 'You cannot instantiate Irkr::Session'
    end
    
    def self.start(nickname, password = nil)
      server  ||= 'irc.freenode.net'
      port    ||= 6667
      sockets ||= {}

      socket = Irkr::Socket.new(server, port.to_i, nickname, password)
      sockets[nickname.to_sym] = socket
    end
    
    def self.send_raw(message)
      sockets.each do |nick, socket|
        socket.send_raw(message)
      end
    end
    
    def self.quit(nickname = nil)
      if nickname
        sockets[nick.to_sym].quit
        sockets[nick.to_sym] = nil
      else
        sockets.each do |nick, socket|
          socket.quit
          sockets[nick] = nil
        end
      end
    end
  end
end
