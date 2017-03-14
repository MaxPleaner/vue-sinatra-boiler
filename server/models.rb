class Todo < ActiveRecord::Base
  include ServerPush

  # Every model should have this defined
  def public_attributes
    attributes
  end
  
end
