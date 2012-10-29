$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'redis'
require 'stemmer'

# The base class. You won't use this directly - use one of the subclasses.
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

  # Format categories for training or untraining.
  #
  # == Parameters
  # categories::
  #   A string or array of categories
  def normalize_categories(categories = [])
    [categories].flatten.collect do |cat|
      cat.to_s.downcase.gsub(/[^a-z\d\.\-_]/,'')
    end.reject{|cat| cat == ''}.compact
  end

  # Count occurences of words in a text corpus.
  #
  # == Parameters
  # text::
  #   A string representing a document.  Stopwords are removed and words are stemmed using the "Stemmer" gem.
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

  # Get a Set of stopwords to remove from documents for training / classifying.
  def stopwords
    @stopwords ||= @stopword_generator.to_set
  end

end

require 'set'
require 'linnaeus/stopwords'
require 'linnaeus/persistence'
require 'linnaeus/trainer'
require 'linnaeus/classifier'
