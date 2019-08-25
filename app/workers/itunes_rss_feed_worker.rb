require 'open-uri'

class ItunesRssFeedWorker
  include Sidekiq::Worker

  def perform
    Feed.where(active: true) do |feed|
      id = feed.itunes_id
      metadata = open("https://itunes.apple.com/lookup?id=#{id}&entity=podcast", read_timeout: 5){ |f| f.read }
      feed_url = JSON.parse(metadata)["results"].first["feedUrl"]
      feed.rss_feed_url = feed_url
      feed.save
    end
  end
end
