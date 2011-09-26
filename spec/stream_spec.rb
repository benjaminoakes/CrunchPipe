require 'spec_helper'

describe CrunchPipe::Stream do
  before(:each) do
    @stream = CrunchPipe::Stream.new do |i|
      i + 1
    end
  end

  it 'is observable' do
    @stream.class.should include(Observable)
  end

  describe 'initialize' do
    context 'given a block' do
      it 'sets block if given' do
        @stream.default_action_block.should_not be_nil
        @stream.default_action_block.should be_an_instance_of(Proc)
      end
    end

    context 'not given a block' do
      it 'does not set a block' do
        stream = CrunchPipe::Stream.new
        stream.default_action_block.should be_nil
      end
    end
  end

  describe '#add' do
    let(:pipeline) { stub(CrunchPipe::Pipeline, :update => true) }
    let(:data) { [1,1,1,1] }

    it 'notifies observers' do
      @stream.add_observer(pipeline)

      @stream.should_receive(:notify_observers).exactly(1).times
      pipeline.should_receive(:update).exactly(1).times

      @stream.add data
    end
  end
end

