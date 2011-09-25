require 'spec_helper'

describe CrunchPipe::Pipeline do
  before(:each) do
    @pipeline_name = 'panda'
    @pipeline_parallel = false
    @pipeline = CrunchPipe::Pipeline.new(:parallel => @pipeline_parallel) {|a|}
  end

  context 'initialization' do
    it "sets parallel flag" do
      @pipeline.parallel.should == @pipeline_parallel
    end

    it 'sets an empty processor array' do
      @pipeline.processors.should == []
    end

    it 'sets an empty connection map' do
      @pipeline.connections.should == {}
    end

    context 'default sink' do
      context 'is not a stream' do
        it 'throws' do
          lambda {
            CrunchPipe::Pipeline.new(:parallel => false, :default_sink => 'panda')
          }.should raise_error
        end
      end

      context 'is a block' do
        it 'does not throw' do
          lambda {
            CrunchPipe::Pipeline.new(:parallel => false) {|a|}
          }.should_not raise_error
        end
      end

      context 'is a stream' do
        it 'does not throw' do
          lambda {
            CrunchPipe::Pipeline.new(:parallel => false, :default_sink => CrunchPipe::Stream.new {|a|})
          }.should_not raise_error
        end
      end

      context 'is not specified' do
        it 'throws' do
          lambda {
            CrunchPipe::Pipeline.new(:parallel => false)
          }.should raise_error
        end
      end
    end
  end

  describe "#register" do
    context 'given a proc' do
      it 'adds proc to pipeline' do
        processor = Proc.new {|a|}
        expect {
          @pipeline.register processor
        }.to change(@pipeline.processors, :count).by(1)

        @pipeline.processors.should include(processor)
      end
    end

    context 'given a block' do
      it 'adds block to pipeline' do
        expect {
          @pipeline.register do |i|
          end
        }.to change(@pipeline.processors, :count).by(1)
      end
    end
  end

  describe '#connect' do
    let(:fake_source) do
      stub(:add_observer => nil,
           :delete_observer => nil)
    end

    it 'subscribes to source' do
      fake_source.should_receive(:add_observer).with(@pipeline)
      @pipeline.connect fake_source
    end

    it 'adds source to connections list' do
      expect {
        @pipeline.connect fake_source
      }.to change(@pipeline.connections, :count).by(1)
    end
  end

  describe '#destroy!' do
    let(:fake_source) do
      stub(:add_observer => nil,
           :delete_observer => nil)
    end

    before(:each) do
      @total = 5

      @total.times do
        @pipeline.connect fake_source.clone
      end
    end

    it 'unsubscribes from all connections' do
      @pipeline.connections.keys.each do |stream|
        stream.should_receive(:delete_observer).with(@pipeline)
      end

      @pipeline.destroy!
    end

    it 'clears connections list' do
      expect {
        @pipeline.destroy!
      }.to change(@pipeline.connections, :count).by(-@total)
    end
  end

  describe '#process' do
    context 'given a single processor' do
      it 'runs element through the processors' do
        @pipeline.register do |elem|
          elem + 1
        end
       
        @pipeline.process(1).should == 2
      end
    end

    context 'given multiple processors' do
      it 'runs element through all processors' do
        n = 5
        
        n.times do
          @pipeline.register lambda {|elem|
            elem + 1
          }
        end
        
        @pipeline.processors.count.should == n
        
        @pipeline.process(1).should == n+1
      end
    end
  end

  describe '#update' do
    let(:data) { [1,1,1,1] }
    let(:output) { stub(CrunchPipe::Stream, :add_observer => true, :add => true) }

    before(:each) do
      @pipeline.register lambda {|elem|
        elem + 1
      }

      @pipeline.connect(output, output)

      @pipeline.parallel = false
    end

    context 'given a non-parallel pipeline' do
      it 'processes all elements' do
        @pipeline.should_receive(:process).with(1).exactly(data.length).times.and_return(2)
        @pipeline.update(output, data)
      end

      it 'adds results to output stream' do
        @pipeline.connections[output].should == output
        output.should_receive(:add).with(data.map {|i| i + 1 })
        @pipeline.update(output, data)
      end
    end

    context 'given a parallel pipeline' do
      before(:each) do
        @pipeline.parallel = true
      end

      it 'processes all elements in parallel' do
        Parallel.should_receive(:map)
        @pipeline.update(output, data)
      end
    end
  end

  describe '.check_arity' do
    context 'given a non-proc' do
      it 'throws' do
        lambda {
          CrunchPipe::Pipeline.check_arity('Panda')
        }.should raise_error
      end
    end

    context 'given a Proc' do
      context 'with an arity of 0' do
        it 'throws' do
          lambda {
            CrunchPipe::Pipeline.check_arity(Proc.new {})
          }.should raise_error
        end
      end

      context 'with an arity of 1' do
        it 'does not throw' do
          lambda {
            CrunchPipe::Pipeline.check_arity(Proc.new {|a|})
          }.should_not raise_error
        end
      end

      context 'with an arity greater than 1' do
        it 'throws' do
          lambda {
            CrunchPipe::Pipeline.check_arity(Proc.new {|a,b|})
          }.should raise_error
        end
      end
    end
  end
end
