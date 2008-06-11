require 'faker'
module Faker
  class Lorem
    def self.unique
      "#{self.words(1)} #{rand()}"
    end
    def self.word
      self.words(1)[0]
    end
  end
end

class Time
  def randomize(variance=100)
    self + rand(variance).days
  end
end

class Fixnum
  def percent_of_the_time(&block)
    raise(ArgumentError, 'Fixnum should be between 1 and 100 to be used with the times method') unless self > 0 && self <= 100
    yield block if (Kernel.rand(99)+1) <= self
  end
end

# (3..6).times do
class Range
  def times(&block)
    list = []

    self.to_a.rand.times do
      list << block.call()
    end

    list
  end
end

# half_the_time do
# sometimes do
class Object
  def half_the_time(&block)
    50.percent_of_the_time {yield}
  end
  alias :sometimes :half_the_time

  def maybe
    rand(10000000) % 2 == 1
  end
end

module ActiveRecord
  class Base
    def self.method_missing_with_examples(method, *args, &blk)
      @custom_examples ||= {}

      if match = method.to_s.match(/(\w*)_example/)
        if block_given?
          @custom_examples[match[0]] = blk
        elsif @custom_examples[match[0]]
          blk = @custom_examples[match[0]]
          input = blk.call(*args)
          if args[0].is_a?(Hash)
            input.merge!(args[0])
          end

          self.create!(input)
        else
          method_missing_without_examples(method, args, &blk)
        end
      else
        method_missing_without_examples(method, args, &blk)
      end
    end
    class << self
      alias method_missing_without_examples method_missing 
      alias method_missing method_missing_with_examples
    end 

    def self.example_attrs(attributes={})
      if @minimum_example_blk
        values = @minimum_example_blk.call(attributes)
        attributes = values.merge(attributes) if values.is_a?(Hash)
      end

      attributes
    end

    def self.example(klass_name={}, attributes={})
      if klass_name.is_a? Symbol
        klass = Object.const_get(klass_name.to_s.camelize)
        klass.example({:full => @full}.merge(attributes))
      else
        attributes = klass_name

        @full = attributes.delete(:full)
        save = attributes.delete(:save)

        if @minimum_example_blk
          values = @minimum_example_blk.call(attributes)
          attributes = values.merge(attributes) if values.is_a?(Hash)
        end

        obj = self.new(attributes)
        obj.save! unless save === false

        if @full && @optional_example_blk
          values = @optional_example_blk.call(obj)
          obj.attributes= values.merge(attributes) if values.is_a?(Hash)
          obj.save!
        end

        return obj
      end
    end

    def self.minimum_example(args={}, &blk)
      if blk
        @minimum_example_blk = blk
      else
        @minimum_example_blk = Proc.new { args }
      end
    end
    def self.optional_example(args={}, &blk)
      if blk
        @optional_example_blk = blk
      else
        @optional_example_blk = Proc.new { args }
      end
    end
  end
end

