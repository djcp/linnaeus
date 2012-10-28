class Linnaeus::Trainer < Linnaeus

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

end
