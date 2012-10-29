# Train or untrain documents from the Bayesian corpus.
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
