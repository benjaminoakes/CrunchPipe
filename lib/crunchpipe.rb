require_relative './pipeline'
require_relative './stream'

module CrunchPipe
  class InvalidProcessorError < Exception
  end
end
