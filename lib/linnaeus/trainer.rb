module Linnaeus
  class Trainer
    include Linnaeus::Helpers

    def initialize(opts = {})
      options = {
        persistence_class: Persistence,
        stopwords_class: Stopwords
      }.merge(opts)

      @db = options[:persistence_class].new(options)
      @stopword_generator = options[:stopwords_class].new
    end

    def train(categories, text)
      categories = normalize_categories categories
      @db.add_categories(categories)

      word_occurrences = count_word_occurrences text
      categories.each do|cat|
        @db.increment_word_counts_for_category cat, word_occurrences
      end
    end

    def untrain(categories, text)
      categories = normalize_categories categories

      word_occurrences = count_word_occurrences text
      categories.each do|cat|
        @db.decrement_word_counts_for_category cat, word_occurrences
        @db.cleanup_empty_words_in_category cat
      end
    end

    def count_word_occurrences(text = '')
      count = {}
      text.downcase.split.each do |word|
        unless stopwords.include? word
          count[word] = count[word] ? count[word] + 1 : 1
        end
      end
      count
    end

    def stopwords
      @stopwords ||= @stopword_generator.to_set
    end

  end
end
