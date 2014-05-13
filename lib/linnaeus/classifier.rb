# Classify documents against the Bayesian corpus.
#
#  lc = Linnaeus::Classifier.new(<options hash>)
#  lc.classify 'a string of text' #a wild category appears
#  lc.classification_scores 'a different string of text' #a hash of categories and scores
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
# redis_connection::
#   An instantiated Redis connection, allowing you to reuse an existing Redis connection.
# redis_host::
#   Passed to persistence class constructor. Defaults to "127.0.0.1"
# redis_port::
#   Passed to persistence class constructor. Defaults to "6379".
# redis_db::
#   Passed to persistence class constructor. Defaults to "0".
# redis_*::
#   Please see Linnaeus::Persistence for the rest of the options that're passed through directly to the Redis client connection.
class Linnaeus::Classifier < Linnaeus

  # Returns a hash of scores for each category in the Bayesian corpus.
  # The closer a score is to 0, the more likely a match it is.
  #
  # == Parameters
  # text::
  #   a string of text to classify.
  #
  # == Returns
  # a hash of categories with a score as the values.
  def classification_scores(text)
    scores = {}

    @db.get_categories.each do |category|
      total_word_count_sum_for_category = @db.get_total_word_count_for_category category

      scores[category] = 0
      words_with_count_for_category = @db.fetch_scores_for_words(category, text.encode(@encoding).downcase.split)
      count_word_occurrences(text).each do |word, count|
        tmp_score = (words_with_count_for_category[word].nil?) ? 0.1 : words_with_count_for_category[word].to_i
        scores[category] += Math.log(tmp_score / total_word_count_sum_for_category.to_f)
      end
    end
    scores
  end

  # The most likely category for a document.
  #
  # == Parameters
  # text::
  #   a string of text to classify.
  #
  # == Returns
  # A string representing the most likely category.
  def classify(text)
    scores = classification_scores(text)
    if scores.any?
      (scores.sort_by { |a| -a[1] })[0][0]
    else
      ''
    end
  end

end
