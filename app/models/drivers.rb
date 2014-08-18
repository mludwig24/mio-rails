class Drivers < ActiveRecord::Base
  belongs_to :app
  validates_presence_of :first_name, :last_name
end
