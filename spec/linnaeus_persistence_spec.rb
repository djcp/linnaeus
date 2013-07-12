require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Persistence do
  before do
    lp = get_linnaeus_persistence
    lp.clear_training_data
  end

  it 'sets keys properly with defaults' do
    lp2 = get_linnaeus_persistence
    train_a_document_in('foobar')
    lp2.redis.keys('*').should eq ['Linnaeus:category', 'Linnaeus:cat:foobar']
  end

  context "custom scopes" do
    it 'sets keys properly' do
      lp2 = get_linnaeus_persistence(scope: 'new-scope')
      lp2.clear_all_training_data

      train_a_document_in('foobar', scope: 'new-scope')

      lp2.redis.keys('*').sort.should eq [
        'Linnaeus:new-scope:cat:foobar', 'Linnaeus:new-scope:category'
      ]
    end

    it 'can clear scoped training data separately' do
      lp = get_linnaeus_persistence

      train_a_document_in('foobar')

      lp2 = get_linnaeus_persistence(scope: 'new-scope')

      train_a_document_in('foobar', scope: 'new-scope')

      lp.redis.keys.sort.should eq [
        "Linnaeus:cat:foobar", "Linnaeus:category",
        "Linnaeus:new-scope:cat:foobar", "Linnaeus:new-scope:category"
      ]

      lp2.clear_training_data

      lp.redis.keys.sort.should eq [
        "Linnaeus:cat:foobar", "Linnaeus:category"
      ]
    end

    it 'stores categories successfully into different scopes' do
      lp = get_linnaeus_persistence
      add_categories lp

      lp2 = get_linnaeus_persistence(scope: 'new-scope')
      add_categories lp2, ['slack' , 'frop']

      lp2.get_categories.sort.should eq ['frop', 'slack']
      lp.get_categories.sort.should eq ['bar','baz','foo']
    end
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

  def add_categories(lp, categories = ['foo','bar','baz','foo', 'bar'])
    lp.add_categories(categories)
  end

  def get_linnaeus_persistence(options = {})
    Linnaeus::Persistence.new(options)
  end

  def train_a_document_in(category, options = {})
    lt = Linnaeus::Trainer.new(options)
    lt.train category, document
  end

  def untrain_a_document_in(category, options = {})
    lt = Linnaeus::Trainer.new(options)
    lt.untrain category, document
  end

  def document
    'I am a test document and I will have stuff in the bayesian corpus'
  end
end
