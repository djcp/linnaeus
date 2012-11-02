require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Persistence do
  before do
    lp = get_linnaeus_persistence
    lp.clear_all_training_data
  end

  it '#clear_all_training_data' do
    lp = get_linnaeus_persistence
    train_a_document_in 'testcategory'
    lp.get_words_with_count_for_category('testcategory').should_not be_empty
    lp.clear_all_training_data
    lp.get_words_with_count_for_category('testcategory').should be_empty
  end

  it 'stores categories successfully' do
    lp = get_linnaeus_persistence
    add_categories lp
    lp.get_categories.sort.should eq ['bar','baz','foo']
  end

  it 'can remove categories' do
    lp = get_linnaeus_persistence
    add_categories lp
    lp.remove_category 'bar'
    lp.get_categories.sort.should eq ['baz','foo']
  end

  it '#get_words_with_count_for_category' do
    lp = get_linnaeus_persistence
    train_a_document_in 'testcategory'
    lp.get_words_with_count_for_category('testcategory').should eq({
      "test"=>"1", "document"=>"1", "stuff"=>"1",
      "bayesian"=>"1", "corpu"=>"1"
    })
  end

  it '#increment_word_counts_for_category' do
    lp = get_linnaeus_persistence
    train_a_document_in 'testcategory'
    train_a_document_in 'testcategory'
    lp.get_words_with_count_for_category('testcategory').should eq({
      "test"=>"2", "document"=>"2", "stuff"=>"2",
      "bayesian"=>"2", "corpu"=>"2"
    })
  end

  it '#decrement_word_counts_for_category' do
    lp = get_linnaeus_persistence
    train_a_document_in 'testcategory'
    train_a_document_in 'testcategory'
    untrain_a_document_in 'testcategory'
    lp.get_words_with_count_for_category('testcategory').should eq({
      "test"=>"1", "document"=>"1", "stuff"=>"1",
      "bayesian"=>"1", "corpu"=>"1"
    })
  end

  it '#cleanup_empty_words_in_category' do
    lp = get_linnaeus_persistence
    train_a_document_in 'testcategory'
    untrain_a_document_in 'testcategory'
    lp.get_words_with_count_for_category('testcategory').should eq ({})
  end

  def add_categories(lp)
    lp.add_categories(['foo','bar','baz','foo', 'bar'])
  end

  def get_linnaeus_persistence
    @lp ||= Linnaeus::Persistence.new
  end

  def train_a_document_in(category)
    lt = Linnaeus::Trainer.new
    lt.train category, document
  end

  def untrain_a_document_in(category)
    lt = Linnaeus::Trainer.new
    lt.untrain category, document
  end

  def document
    'I am a test document and I will have stuff in the bayesian corpus'
  end
end
