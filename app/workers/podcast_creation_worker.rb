class PodcastImportWorker
  include Sidekiq::Worker

  def perform
    Feed.where(active: true).find_each do |feed|
      rss_url = feed.rss_url
      # Import Podcast
    end
  end
end
