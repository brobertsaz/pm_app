class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :project_templates, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def full_name
    email.split('@').first.titleize
  end
end
