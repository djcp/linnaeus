$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'redis'
require 'stemmer'

module Linnaeus
  module Helpers
    def normalize_categories(categories = [])
      [categories].flatten.collect do |cat|
        cat.to_s.downcase.gsub(/[^a-z\d\.\-_]/,'')
      end.reject{|cat| cat == ''}.compact
    end
  end
end

require 'set'
require 'linnaeus/stopwords'
require 'linnaeus/persistence'
require 'linnaeus/trainer'
#require 'linnaeus/classifier'
#require 'linnaeus/stopwords'
#require 'linnaeus/tokenizer'
