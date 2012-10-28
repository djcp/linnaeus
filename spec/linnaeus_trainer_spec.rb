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
  end

  context 'with non-default stopwords' do
    subject { Linnaeus::Trainer.new(stopwords_class: FooStop) }
    it 'should count word occurrencs properly' do
      subject.count_word_occurrences('foo bar foo baz').should == { 'baz' => 1 }
    end
  end
end

class FooStop
  def to_set
    Set.new ['foo','bar']
  end
end
