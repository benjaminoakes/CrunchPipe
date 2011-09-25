module CrunchPipe
  class Cruncher
    attr_reader :pipelines, :streams

    def initialize
      @pipelines = {}
      @streams = []
    end

    def add_pipeline(pipeline)
      @pipelines[pipeline.name] = pipeline
    end

    def add_data_source(stream)
      @streams.push stream
    end
  end
end
