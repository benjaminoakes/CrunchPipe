module CrunchPipe
  class Pipeline
    attr_accessor :parallel
    attr_reader :processors, :connections, :default_sink
    
    def initialize(args, &block)
      @parallel = args[:parallel]

      if args[:default_sink].is_a?(CrunchPipe::Stream)
        @default_sink = args[:default_sink]
      elsif block_given?
        @default_sink = CrunchPipe::Stream.new &block
      else
        fail CrunchPipe::InvalidPipelineError, "Pipelines must be given either an endpoint Stream or a default action block"
      end

      @processors = []
      @connections = {}
    end
    
    def register(processor = nil, &block)
      if block_given?
        Pipeline.check_arity(block)
        @processors.push block
      elsif processor
        Pipeline.check_arity(processor)
        @processors.push processor
      end
    end

    def connect(stream, sink = nil)
      stream.add_observer(self)
      @connections[stream] = sink || @default_sink
    end

    def destroy!
      @connections.keys.each do |stream|
        stream.delete_observer(self)
      end

      @connections.clear
    end

    def update(stream, elements)
      if @parallel
        results = Parallel.map(elements) {|element| process element }
      else
        results = elements.map {|element| process element }
      end

      @connections[stream].add results

      results
    end

    def process(element)
      result = element
      @processors.each do |processor| 
        result = processor.yield(result) 
      end

      result
    end

    def self.check_arity(processor)
      unless processor.is_a?(Proc)
        fail CrunchPipe::InvalidProcessorError, "Processor must be a Proc but was a #{processor.class}"
      end

      unless processor.arity == 1
        fail CrunchPipe::InvalidProcessorError, "Processor must take 1 argument but instead takes #{processor.arity}"
      end
    end
  end
end
