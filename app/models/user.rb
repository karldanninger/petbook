class User < ActiveRecord::Base
  attr_accessible :name, :email, :photo, :password, :password_confirmation, :pettype, :breed, :birthday
attr_accessor :photo_file_name
  has_secure_password
  
  belongs_to :page
  has_attached_file :photo,
  :styles =>{
    :thumb  => "100x100",
    :medium => "200x200",
    :large => "600x400"
  },
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :default_url => "kitty.jpeg",
  :bucket => 'petbook-assets'

  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: "Relationship",
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { |user| user.email = user.email.downcase }
  before_save :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :pettype,  presence: true, length: { maximum: 50 }
  validates :breed,  presence: true, length: { maximum: 50 }
  validates_date :birthday, :on_or_before => lambda { Date.current }

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
