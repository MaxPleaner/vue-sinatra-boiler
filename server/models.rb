class Todo < ActiveRecord::Base
  include ServerPush
  def public_attributes
    attributes
  end
end
