require 'thread'
require 'observer'

module CrunchPipe
  class Stream
    include Observable

    attr_reader :default_action_block

    def initialize(&block)
      if block_given?
        @default_action_block = block
      end
    end

    def add(elements = [])
      changed
      notify_observers(self, elements)
      @default_action_block && elements.each {|element| @default_action_block.call element }
    end
  end
end
