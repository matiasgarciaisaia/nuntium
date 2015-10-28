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

require 'test_helper'

class Telemetry::AtCountCollectorTest < ActiveSupport::TestCase

  def setup
    @now = Time.now
    @beginning = @now - 7.days
    @end = @now
    @period = InsteddTelemetry::Period.new beginning: @beginning, end: @end

    account = Account.make

    @channel_1 = QstServerChannel.make account: account
    @channel_2 = QstServerChannel.make account: account
    @channel_3 = QstServerChannel.make account: account

    AtMessage.make account: account, channel: @channel_1, created_at: @end - 1.day
    AtMessage.make account: account, channel: @channel_1, created_at: @end - 10.days
    AtMessage.make account: account, channel: @channel_1, created_at: @end - 365.days
    AtMessage.make account: account, channel: @channel_1, created_at: @end + 1.day

    AtMessage.make account: account, channel: @channel_2, created_at: @end - 30.days
    AtMessage.make account: account, channel: @channel_2, created_at: @end - 40.days

    AtMessage.make account: account, channel: @channel_3, created_at: @end + 7.day
  end

  test 'should collect at messages' do
    stats = Telemetry::AtCountCollector.collect_stats(@period)
    counters = stats[:counters]

    assert_equal(2, counters.size)

    channel_1_stats = counters.find{|x| x[:key][:channel_id] == @channel_1.id}
    channel_2_stats = counters.find{|x| x[:key][:channel_id] == @channel_2.id}

    assert_equal(channel_1_stats, {
      metric: 'at_messages',
      key: {channel_id: @channel_1.id},
      value: 3
    })

    assert_equal(channel_2_stats, {
      metric: 'at_messages',
      key: {channel_id: @channel_2.id},
      value: 2
    })
  end

end
