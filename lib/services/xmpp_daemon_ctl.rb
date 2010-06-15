#!/usr/bin/ruby
require(File.join(File.dirname(__FILE__), 'generic_ctl'))
if ARGV.length != 4
  puts "Usage: ./xmpp_daemon_ctl.rb start -- <environment> <channel_id>"
else
  run('xmpp_daemon', ARGV[3])
end