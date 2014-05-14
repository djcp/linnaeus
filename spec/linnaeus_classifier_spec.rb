require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Linnaeus::Classifier do
  context 'with no training data' do
    it 'should return empty values when attempting to classify' do
      Linnaeus::Persistence.new.clear_all_training_data
      subject.classify("foo bar baz").should be_empty
      subject.classification_scores("foo bar baz").should be_empty
    end
  end

  context 'with a very small dataset' do
    before do
      create_small_dataset
    end

    it 'should classify easy things well' do
      subject.classify('A bird that migrates').should eq('bird')
      subject.classify('This was directed by Gus Van Sant').should eq('movie')
    end

    it 'should return correct classification scores' do
      subject.classification_scores('a bird').should eq(
        { "movie"=>-6.272877006546167, "bird"=>-4.2626798770413155 }
      )
      subject.classification_scores('a directorial bird').should eq(
        { "movie"=>-12.545754013092335, "bird"=>-10.827944847076676 }
      )
    end
  end

  def create_small_dataset
    Linnaeus::Persistence.new.clear_all_training_data
    lt = Linnaeus::Trainer.new
    lt.train 'movie', "Gone with the Wind is a 1939 American historical epic film adapted from Margaret Mitchell's Pulitzer-winning 1936 novel of the same name."
    lt.train 'movie', "THX 1138 is a 1971 science fiction film directed by George Lucas in his feature directorial debut. The film was written by Lucas and Walter Murch."
    lt.train 'movie', "Top Gun is a 1986 American action drama film directed by Tony Scott, and produced by Don Simpson and Jerry Bruckheimer, in association with the Paramount Pictures company."

    lt.train 'bird', "The Yellow-throated Warbler (Setophaga dominica) is a small migratory songbird species breeding in temperate North America. It belongs to the New World warbler family (Parulidae)."
    lt.train 'bird', "The Blue Jay (Cyanocitta cristata) is a passerine bird in the family Corvidae, native to North America. It is resident through most of eastern and central United States and southern Canada, although western populations may be migratory."
    lt.train 'bird', "The Mallard or Wild Duck (Anas platyrhynchos) is a dabbling duck which breeds throughout the temperate and subtropical Americas, Europe, Asia, and North Africa, and has been introduced to New Zealand and Australia. This duck belongs to the subfamily Anatinae of the waterfowl family Anatidae"
  end
end
