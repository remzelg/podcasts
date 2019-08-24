class FeedGenerationWorker
  include Sidekiq::Worker

  def perform
    puts 'wot'
  end
end
