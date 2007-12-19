require 'rkelly/tokenizer'
require 'rkelly/generated_parser'

module RKelly
  class Parser < RKelly::GeneratedParser
    TOKENIZER = Tokenizer.new
    def initialize
      @tokens = []
      @logger = nil
    end

    # Parse +javascript+ and return an AST
    def parse(javascript)
      @tokens = TOKENIZER.tokenize(javascript)
      @position = 0
      SourceElementList.new([do_parse].flatten)
    end

    private
    def on_error(error_token_id, error_value, value_stack)
    end

    def next_token
      return [false, false] if @position >= @tokens.length
      n_token = @tokens[@position]
      @position += 1
      n_token
    end
  end
end