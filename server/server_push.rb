# included into ActiveRecord models
module ServerPush

  # Can be overridden in model to limit who gets updates
  # Returns a list of sockets (by default all of them)
  def publish_to
    Sockets.values.map(&:to_a).flatten
  end

  def save(*args)
    should_push = valid? && !persisted?
    result = super(*args)
    if should_push
      publish_to.each do |socket|
        socket.send({
          action: "add_record",
          type: self.class.to_s.underscore,
          record: public_attributes
        }.to_json)
      end
    end
    result
  end

  def update(*args)
    result = super(*args)
    if result
      publish_to.each do |socket|
        socket.send({
          action: "update_record",
          type: self.class.to_s.underscore,
          record: public_attributes  
        }.to_json)
      end
    end
    result
  end

  def destroy(*args)
    result = super(*args)
    unless persisted?
      publish_to.each do |socket|
        socket.send({
          action: "destroy_record",
          type: self.class.to_s.underscore,
          record: public_attributes  
        }.to_json)
      end
    end
    result
  end  

end
