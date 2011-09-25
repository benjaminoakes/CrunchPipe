require 'thread'
require 'observer'

module CrunchPipe
  class Stream
    include Observable

    def initialize(&block)
      if block_given?
        @block = block
      end
    end

    def add(elements = [])
      notify_observers(self, elements)
      @block && elements.each {|element| @block.call element }
    end
  end
end
