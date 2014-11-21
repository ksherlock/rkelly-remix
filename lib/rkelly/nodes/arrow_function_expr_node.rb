module RKelly
  module Nodes
    class ArrowFunctionExprNode < FunctionExprNode
      # body may be a function body or an expression.
      def initialize(body, args = [])
        super(nil, body, args)
      end

      def statement?
        @function_body.is_a? FunctionBodyNode
      end

      def expression?
        !@function_body.is_a? FunctionBodyNode
      end

    end
  end
end
