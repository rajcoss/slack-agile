# A collection of GitHub events with chainable filters
class EventCollection < ChainableCollection
  def reverse_chronological
    wrap(
      sort do |a, b|
        Time.zone.parse(b['created_at']) <=> Time.zone.parse(a['created_at'])
      end,
    )
  end

  def labeled(x)
    wrap(
      @inner.select do |event|
        event['event'] == 'labeled' &&
          event['label'].name.downcase == x.downcase
      end,
    )
  end
end
