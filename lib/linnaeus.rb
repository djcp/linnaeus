$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'redis'
require 'stemmer'

class Linnaeus

  def initialize(opts = {})
    options = {
      persistence_class: Persistence,
      stopwords_class: Stopwords,
      skip_stemming: false
    }.merge(opts)

    @db = options[:persistence_class].new(options)
    @stopword_generator = options[:stopwords_class].new
    @skip_stemming = options[:skip_stemming]
  end

  def normalize_categories(categories = [])
    [categories].flatten.collect do |cat|
      cat.to_s.downcase.gsub(/[^a-z\d\.\-_]/,'')
    end.reject{|cat| cat == ''}.compact
  end

  def count_word_occurrences(text = '')
    count = {}
    text.downcase.split.each do |word|
      stemmed_word = (@skip_stemming) ? word : word.stem_porter
      unless stopwords.include? stemmed_word
        count[stemmed_word] = count[stemmed_word] ? count[stemmed_word] + 1 : 1
      end
    end
    count
  end

  def stopwords
    @stopwords ||= @stopword_generator.to_set
  end

end

require 'set'
require 'linnaeus/stopwords'
require 'linnaeus/persistence'
require 'linnaeus/trainer'
require 'linnaeus/classifier'
