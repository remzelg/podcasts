class Feed < ApplicationRecord
  # Contains all logic for importing, creating, and processing podcasts.
  # Should have nothing to do with the usage of podcasts once they are created.
  has_one :podcast
end
