RSpec.describe FeedGenerationWorker do
  describe '#perform' do
    it 'works' do
      described_class.new.perform
    end
  end
end
