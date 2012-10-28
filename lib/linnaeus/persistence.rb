module Linnaeus
  class Persistence
    CATEGORIES_KEY = 'Linnaeus:category'
    BASE_CATEGORY_KEY = 'Linnaeus:cat:'

    attr_accessor :redis

    def initialize(opts = {})
      options = {
        redis_host: '127.0.0.1',
        redis_port: '6379',
        redis_db: 0
      }.merge(opts)

      @redis = Redis.new(
        host: options[:redis_host],
        port: options[:redis_port],
        db: options[:redis_db]
      )
      self
    end

    def add_categories(categories)
      @redis.sadd CATEGORIES_KEY, categories
    end

    def remove_category(category)
      @redis.srem CATEGORIES_KEY, category
    end

    def get_categories
      @redis.smembers CATEGORIES_KEY
    end

    def get_words_with_count_for_category(category)
      @redis.hgetall BASE_CATEGORY_KEY + category
      #@redis.hgetall(BASE_CATEGORY_KEY + category).inject(0) {|sum, count| sum += count.to_i}
    end

    def clear_all_training_data
      @redis.flushdb
    end

    def increment_word_counts_for_category(category, word_occurrences)
      @redis.multi do |multi|
        word_occurrences.each do|word,count|
          multi.hincrby BASE_CATEGORY_KEY + category, word, count
        end
      end
    end

    def decrement_word_counts_for_category(category, word_occurrences)
      @redis.multi do |multi|
        word_occurrences.each do|word,count|
          multi.hincrby BASE_CATEGORY_KEY + category, word, - count
        end
      end
    end

    def cleanup_empty_words_in_category(category)
      word_counts = @redis.hgetall BASE_CATEGORY_KEY + category
      cleaned_word_count = word_counts.reject{|word, count| count.to_i <= 0}
      if cleaned_word_count.empty?
        @redis.del BASE_CATEGORY_KEY + category
      else
        @redis.mapped_hmset BASE_CATEGORY_KEY + category, cleaned_word_count
      end
    end

  end
end
