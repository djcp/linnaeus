class Linnaeus::Classifier < Linnaeus

  def classification_scores(text)
    scores = {}

    @db.get_categories.each do |category|
      words_with_count_for_category = @db.get_words_with_count_for_category category
      total_word_count_sum_for_category = words_with_count_for_category.values.reduce(0){|sum, count| sum += count.to_i}

      scores[category] = 0
      count_word_occurrences(text).each do |word, count|
        tmp_score = (words_with_count_for_category[word].nil?) ? 0.1 : words_with_count_for_category[word].to_i
        scores[category] += Math.log(tmp_score / total_word_count_sum_for_category.to_f)
      end
    end
    scores
  end

  def classify(text)
    (classification_scores(text).sort_by { |a| -a[1] })[0][0]
  end

end
