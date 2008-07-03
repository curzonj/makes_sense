class Platform
  class << self
    def linux?
      RUBY_PLATFORM =~ /linux$/ ? true : false
    end

    def win32?
     RUBY_PLATFORM =~ /(win|w)32$/ ? true : false
    end
  end
end


