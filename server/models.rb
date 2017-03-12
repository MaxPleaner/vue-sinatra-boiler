class Todo < ActiveRecord::Base
  def public_attributes
    attributes
  end
end
