module Telemetry::ChannelsByTypeCollector
  def self.collect_stats(period)
    channels_by_kind = Channel.where('created_at < ?', period.end).group(:kind).count
    counters = channels_by_kind.map do |kind, count|
      {
        metric: 'channels_by_kind',
        key: {kind: kind},
        value: count
      }
    end

    {counters: counters}
  end
end
