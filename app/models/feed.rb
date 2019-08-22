class Feed < ApplicationRecord
  has_many :episodes, dependent: :destroy
end
