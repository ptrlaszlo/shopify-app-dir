class ApplicationSnapshot < ActiveRecord::Base

  belongs_to :application_link
  has_and_belongs_to_many :categories
end
