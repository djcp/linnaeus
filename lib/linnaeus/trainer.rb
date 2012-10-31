# Train or untrain documents from the Bayesian corpus.
#
#  lt = Linnaeus::Trainer.new(<options hash>)
#  lt.train 'category', 'a string of text' 
#  lt.train 'differentcategory', 'another string of text' 
#  lt.untrain 'category', 'a document we just removed'
#
# == Constructor Options
# persistence_class::
#   A class implementing persistence - the default (Linnaeus::Persistence) uses redis.
# stopwords_class::
#   A class that emits a set of stopwords. The default is Linnaeus::Stopwords
# skip_stemming::
#   Set to true to skip porter stemming.
# encoding::
#   Force text to use this character set. UTF-8 by default.
# redis_host::
#   Passed to persistence class constructor. Defaults to "127.0.0.1"
# redis_port::
#   Passed to persistence class constructor. Defaults to "6379".
# redis_db::
#   Passed to persistence class constructor. Defaults to "0".
# redis_*::
#   Please see Linnaeus::Persistence for the rest of the options that're passed through directly to the Redis client connection.
class Linnaeus::Trainer < Linnaeus

  # Add a document to the training corpus.
  #
  # == Parameters
  # categories::
  #   A string or array of categories
  # text::
  #   A string of text in this document.
  def train(categories, text)
    categories = normalize_categories categories
    @db.add_categories(categories)

    word_occurrences = count_word_occurrences text
    categories.each do|cat|
      @db.increment_word_counts_for_category cat, word_occurrences
    end
  end

  # Remove a document from the training corpus.
  #
  # == Parameters
  # categories::
  #   A string or array of categories
  # text::
  #   A string of text in this document.
  def untrain(categories, text)
    categories = normalize_categories categories

    word_occurrences = count_word_occurrences text
    categories.each do|cat|
      @db.decrement_word_counts_for_category cat, word_occurrences
      @db.cleanup_empty_words_in_category cat
    end
  end

end
