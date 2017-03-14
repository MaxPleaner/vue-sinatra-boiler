class Todo < ActiveRecord::Base
  include ServerPush

  def save(*args)
    self.text ||= ""
    super(*args)
  end

  # Every model should have this defined
  def public_attributes
    attributes
  end
  
end
