class Tag < ApplicationRecord
  belongs_to :project
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :color, presence: true
end
