class Quiz < ActiveRecord::Base
  belongs_to :user

  belongs_to :person
  validates :person, :presence => true
  
  delegate :name, :diaspora_handle, :guid, :first_name,
           to: :person, prefix: true

  has_many :questions
end  
  