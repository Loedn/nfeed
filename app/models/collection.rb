class Collection < ApplicationRecord
    validates :name, presence: true
    validates :category, presence: true

    has_many :feeds, dependent: :destroy

    CATEGORIES = [
        "Technology",
        "News",
        "Finance",
        "Entertainment",
        "Science",
        "Sports",
        "Health",
        "Education",
        "Art",
        "Food",
        "Video Games",
        "Gaming",
        "Food",
        "Travel",
        "Personal"
    ].freeze

    scope :by_category, -> { order(:category, :name) }

    def self.grouped_by_category
        all.group_by(&:category)
    end
end
