module ChannelQstConfiguration
  def account
    @account ||= Account.find_by_id(@account_id)
  end

  def channel
    @channel ||= account.find_channel @channel_id
  end

  def get_url_user_and_password
    [channel.configuration[:url], channel.configuration[:user], channel.configuration[:password]]
  end

  def on_401(message)
    channel.logger.error :channel_id => channel.id, :message => message
    channel.enabled = false
    channel.save!
  end

  def on_exception(message)
    channel.logger.error :channel_id => channel.id, :message => message
  end
end