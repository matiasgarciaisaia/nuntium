#!/usr/bin/ruby
require(File.join(File.dirname(__FILE__), 'generic_daemon'))
if ARGV.length != 2
  puts "Usage: ./xmpp_daemon.rb <environment> <channel_id>"
else
  start_service "xmpp_daemon_#{ARGV[1]}" do
    channel_id = ARGV[1]
    channel = Channel.find_by_id channel_id
    if not channel
      Rails.logger.error "No channel found for id #{channel_id}"
    elsif channel.kind != 'xmpp'
      Rails.logger.error "Channel #{channel.name} is not an XMPP channel"
    else
      XmppService.new(channel).start
      EM.reactor_thread.join
    end
  end
end