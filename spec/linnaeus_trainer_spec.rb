require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Trainer do
  context 'with default options' do
    subject { Linnaeus::Trainer.new }

    it 'should count word occurrencs properly' do
      subject.count_word_occurrences('foo bar foo baz').should == 
        { 'foo' => 2, 'bar' => 1, 'baz' => 1 }
    end

    it 'should not count stopwords' do
      subject.count_word_occurrences('foo the you').should == { 'foo' => 1 }
    end

    it 'returns an empty hash when given an empty string' do
      subject.count_word_occurrences.should == { }
    end

    it 'should train on documents properly' do
      lp = Linnaeus::Persistence.new
      lp.clear_all_training_data
      subject.train 'fruit', grape
      subject.train 'fruit', orange
      lp.get_words_with_count_for_category('fruit').should eq(
        {
        "grape"=>"1", "purpl"=>"1", "blue"=>"1", "green"=>"1", 
        "fruit"=>"2", "sweet"=>"2", "wine"=>"1", "oval"=>"1", 
        "orang"=>"1", "round"=>"1", "citru"=>"1"
      })
    end

    it 'should partially untrain properly' do
      lp = Linnaeus::Persistence.new
      lp.clear_all_training_data
      subject.train 'fruit', grape
      subject.train 'fruit', orange

      subject.untrain 'fruit', grape
      lp.get_words_with_count_for_category('fruit').should eq({"fruit"=>"1", "sweet"=>"1", "orang"=>"1", "round"=>"1", "citru"=>"1"})
    end

    it 'should fully untrain properly' do
      lp = Linnaeus::Persistence.new
      lp.clear_all_training_data
      subject.train 'fruit', grape
      subject.untrain 'fruit', grape
      lp.get_words_with_count_for_category('fruit').should eq({})
    end

  end

  context 'with non-default stopwords' do
    subject { Linnaeus::Trainer.new(stopwords_class: FooStop) }
    it 'should count word occurrencs properly' do
      subject.count_word_occurrences('foo bar foo baz').should == { 'baz' => 1 }
    end
  end

  def grape
    'grape purple blue green fruit sweet wine oval'
  end

  def orange
    'orange round citrus fruit sweet'
  end
end

class FooStop
  def to_set
    Set.new ['foo','bar']
  end
end
