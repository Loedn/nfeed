class Collection < ApplicationRecord
    validates :name, presence: true

    has_many :feeds, dependent: :destroy

end
