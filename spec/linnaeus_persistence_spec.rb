require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Persistence do
  it 'stores categories successfully' do
    lp = Linnaeus::Persistence.new
    lp.clear_all_training_data
    add_categories lp
    lp.get_categories.sort.should eq ['bar','baz','foo']
  end

  it 'can remove categories' do
    lp = Linnaeus::Persistence.new
    lp.clear_all_training_data
    add_categories lp
    lp.remove_category 'bar'
    lp.get_categories.sort.should eq ['baz','foo']
  end

  def add_categories(lp)
    lp.add_categories(['foo','bar','baz','foo', 'bar'])
  end
end
