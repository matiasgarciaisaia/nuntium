require 'rss/1.0'
require 'rss/2.0'

class RssController < ApplicationController
  before_filter :authenticate

  # GET /rss
  def index
    last_modified = request.env['HTTP_IF_MODIFIED_SINCE']
    etag = request.env['HTTP_IF_NONE_MATCH']
    
    # Filter by application
    query = 'application_id = ? AND (state = ? OR state = ?)'
    params = [@application.id, 'queued', 'delivered']
    
    # Filter by date if requested
    if !last_modified.nil?
      query += ' AND timestamp > ?'
      params.push DateTime.parse(last_modified)
    end
    
    # Order by time, last arrived message will be first
    @at_messages = ATMessage.all(:order => 'timestamp DESC', :conditions => [query] + params)
    
    if @at_messages.empty?
      head :not_modified
      return
    end
    
    if !etag.nil?
      # If there's an etag, find the matching message and collect up to it in temp_messages
      temp_messages = []
      @at_messages.each do |msg|
        if msg.guid == etag
          break
        end
        temp_messages.push msg
      end
      
      if temp_messages.empty?
        head :not_modified
        return
      end
      
      @at_messages = temp_messages
    end
    
    # Reverse is needed to have the messages shown in ascending timestamp
    @at_messages.reverse!
    
    # Get the ids of the messages to be shown
    at_messages_ids = @at_messages.collect {|x| x.id}
    
    # And increment their tries
    ATMessage.update_all("state = 'delivered', tries = tries + 1", ['id IN (?)', at_messages_ids])
    
    # Separate messages into ones that have their tries
    # over max_tries and those still valid.
    valid_messages, invalid_message_ids = filter_tries_exceeded_and_not_exceeded @at_messages, @application
    
    # Mark as failed messages that have their tries over max_tries
    if !invalid_message_ids.empty?
      ATMessage.update_all(['state = ?', 'failed'], ['id IN (?)', invalid_message_ids])
    end
    
    # Logging: say that valid messages were returned and invalid no
    ATMessage.log_delivery(@at_messages, @application, 'rss')
    
    @at_messages = valid_messages
    if @at_messages.empty?
      head :not_modified
      return
    end
    
    response.last_modified = @at_messages.last.timestamp
    render :layout => false
  end
  
  # POST /rss
  def create
    body = request.env['RAW_POST_DATA']
    tree = RSS::Parser.parse(body, false)
    
    tree.channel.items.each do |item|
      # Create AO message
      msg = AOMessage.new
      msg.application_id = @application.id
      msg.from = item.author
      msg.to = item.to
      msg.subject = item.title
      msg.body = item.description
      msg.guid = item.guid.content
      msg.timestamp = item.pubDate.to_datetime
      
      # And let the application handle it
      @application.route msg, 'rss'
    end
     
    head :ok
  end
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      @application = Application.find_by_id_or_name(username)
      if !@application.nil? and @application.interface == 'rss'
        @application.authenticate password
      else
        false
      end
    end
  end
end

# Define 'to' tag inside 'item'
module RSS; class Rss; class Channel; class Item
  install_text_element "to", "", '?', "to", :string, "to"
end; end; end; end

RSS::BaseListener.install_get_text_element "", "to", "to="