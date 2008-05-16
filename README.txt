== Irkr

Irkr is a gem that provides a Ruby interface for IRC.

== Sample Usage

session = Irkr::Session.start('bscofield')
session.join('#tester')
session.connect
session.tell('#tester', 'hello world!')
session.command('NICK not_bscofield')
session.quit
