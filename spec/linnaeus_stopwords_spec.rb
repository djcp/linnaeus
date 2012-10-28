require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Stopwords do
  subject { Linnaeus::Stopwords.new }
  it '.to_a' do
    subject.should respond_to :to_a
    subject.to_a.should be_an_instance_of Array
    subject.to_a.should include 'the'
  end
  it '.to_set' do
    subject.should respond_to :to_set
    subject.to_set.should be_an_instance_of Set
    subject.to_set.should include 'the'
  end
  it 'can have stopwords overridden' do
    subject.stopwords = ['foo','bar']
    subject.to_a.should eq ['foo','bar']
    subject.to_set.should eq ['foo','bar'].to_set
  end
end
