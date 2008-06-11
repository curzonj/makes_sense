class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method, *args)
    send(method, *args) if respond_to? method
  end
end

# Use only with extreme care
class BlackHole
  def method_missing(method, *args)
    return self
  end
  
  def self.method_missing(method, *args)
    return self
  end
end
