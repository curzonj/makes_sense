module ActsAsFerret
  class FerretResult
    def lazy_data
      @data
    end
  end
end

module MakesSense
  module FerretWithoutStopWords
    def acts_as_ferret_without_stopwords(field_options={}, ferret_options={})
      ferret_options[:analyzer] ||= Ferret::Analysis::StandardAnalyzer.new(nil)
      acts_as_ferret field_options, ferret_options
    end
  end
end

ActiveRecord::Base.extend MakesSense::FerretWithoutStopWords
