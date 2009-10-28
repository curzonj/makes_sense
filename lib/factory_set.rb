# Used by cucumber to prep the database with larger sets of example data. The
# method names are matched against factory_girl factories and the parameters
# are passed in as is. It's just a terse way to create data sets.
#
#   FactorySet.new(:users) do
#     user :first_name => "Bob"
#   end
#  
#   FactorySet.new(:directory) do
#     include :users
#     podcast :itunes_category => itunes_category(:name => "Church")
#   end
#  
#   FactorySet[:directory].load
#
# The blocks are not evaluated until you call load so you can directly reference
# model classes if need be without damage.
#
class FactorySet
  class << self
    def [](name)
      sets[name.to_s]
    end

    def sets
      @sets ||= {}
    end
  end

  def initialize(name, &block)
    self.class.sets[name.to_s] = self
    @block = block
  end

  def method_missing(sym, *args)
    Factory.create(sym, *args)
  end

  def include(name)
    self.class[name].load
  end

  # Evaluate the block, this loads the database.
  def load
    instance_eval(&@block)
  end
end
