# The redis persistence layer.
class Linnaeus::Persistence < Linnaeus
  attr_accessor :redis

  def initialize(opts = {})
    options = {
      redis_host: '127.0.0.1',
      redis_port: '6379',
      redis_db: 0,
      redis_scheme: "redis",
      redis_path: nil,
      redis_timeout: 5.0,
      redis_password: nil,
      redis_id: nil,
      redis_tcp_keepalive: 0,
      scope: nil
    }.merge(opts)

    @scope = options[:scope]

    @redis = Redis.new(
      host: options[:redis_host],
      port: options[:redis_port],
      db: options[:redis_db],
      scheme: options[:redis_scheme],
      path: options[:redis_path],
      timeout: options[:redis_timeout],
      password: options[:redis_password],
      id: options[:redis_id],
      tcp_keepalive: options[:redis_tcp_keepalive]
    )

    self
  end

  # Add categories to the bayesian corpus.
  #
  # == Parameters
  # categories::
  #   A string or array of categories.
  def add_categories(categories)
    @redis.sadd category_collection_key, categories
  end

  # Remove categories from the bayesian corpus
  #
  # == Parameters
  # categories::
  #   A string or array of categories.
  def remove_category(category)
    @redis.srem category_collection_key, category
  end

  # Get categories from the bayesian corpus
  #
  # == Parameters
  # categories::
  #   A string or array of categories.
  def get_categories
    @redis.smembers category_collection_key
  end

  # Get a list of words with their number of occurrences.
  # 
  # == Parameters
  # category::
  #   A string representing a category.
  #
  # == Returns
  # A hash with the word counts for this category.
  def get_words_with_count_for_category(category)
    @redis.hgetall base_category_key + category
  end

  # Clear all training data from the backend.
  def clear_all_training_data
    @redis.flushdb
  end

  # Clear training data for the scope associated with this instance.
  def clear_training_data
     keys = @redis.keys(base_key.join(':') + '*')

     keys.each do |key|
       @redis.del key
     end
  end

  # Increment word counts within a category
  #
  # == Parameters
  # category::
  #   A string representing a category.
  # word_occurrences::
  #   A hash containing a count of the number of word occurences in a document
  def increment_word_counts_for_category(category, word_occurrences)
    word_occurrences.each do|word,count|
      @redis.hincrby base_category_key + category, word, count
    end
  end

  # Decrement word counts within a category. This is used when removing a document from the corpus.
  #
  # == Parameters
  # category::
  #   A string representing a category.
  # word_occurrences::
  #   A hash containing a count of the number of word occurences in a document
  def decrement_word_counts_for_category(category, word_occurrences)
    word_occurrences.each do|word,count|
      @redis.hincrby base_category_key + category, word, - count
    end
  end

  # Clean out words with a count of zero in a category. Used during untraining.
  #
  # == Parameters
  # category::
  #   A string representing a category.
  def cleanup_empty_words_in_category(category)
    word_counts = @redis.hgetall base_category_key + category
    empty_words = word_counts.select{|word, count| count.to_i <= 0}
    if empty_words == word_counts
      @redis.del base_category_key + category
    else
      if empty_words.any?
        @redis.hdel base_category_key + category, empty_words.keys
      end
    end
  end

  private

  # The Set (in the redis sense) of categories are stored in this key.
  def category_collection_key
    [ base_key, 'category' ].compact.join(':')
  end

  # The base key for a category within a scope in the redis corpus. Word
  # occurrence counts for a category appear under here.
  def base_category_key
    [ base_key, 'cat:' ].flatten.join(':')
  end

  def base_key
    [ 'Linnaeus', @scope ].compact
  end

end
