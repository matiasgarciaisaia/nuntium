# Copyright (C) 2009-2012, InSTEDD
# 
# This file is part of Nuntium.
# 
# Nuntium is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Nuntium is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Nuntium.  If not, see <http://www.gnu.org/licenses/>.

class PullQstChannelMessageJob < AbstractPullQstMessageJob
  include ChannelQstConfiguration

  def initialize(account_id, channel_id)
    @account_id = account_id
    @channel_id = channel_id
    @batch_size = 10
  end

  def message_class
    AtMessage
  end

  def load_last_id
    channel.last_at_guid
  end

  def save_last_id(last_id)
    channel.last_at_guid = last_id
    channel.save!
  end

  def route(msg)
    account.route_at msg, channel
  end
end
