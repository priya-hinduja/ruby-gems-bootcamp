class User < ApplicationRecord
  rolify
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :confirmable

  friendly_id :email, use: :slugged

  has_many :courses
  has_many :enrollments
  after_create :assign_default_role

  validate :must_have_a_role, on: :update

  def to_s
    email
  end

  def username
    self.email.split(/@/).first
  end

  def assign_default_role
    # self.add_role(:student) if self.roles.blank?
    if User.count == 1
      add_role(:admin) if roles.blank?
      add_role(:teacher)
      add_role(:student)
    else
      add_role(:student) if roles.blank?
      add_role(:teacher) # if you want any user to be able to create own courses
    end
  end

  def online?
    updated_at > 2.minutes.ago
  end

  def buy_course(course)
    self.enrollments.create(course: course, price: course.price)
  end

  private

  def must_have_a_role
    unless roles.any?
      errors.add(:roles, "must have atleast one role")
    end
  end

end
