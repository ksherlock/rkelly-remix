require 'rkelly/nodes'

module RKelly
  module Visitors


    class ES_6_5_Visitor < ECMAVisitor

      include RKelly::Nodes


      #
      # converts function(...args) { ... }
      # into 
      # function() { var args = Array.prototype.slice(arguments, ?); ... }
      def fxtransform(o)


        return o unless o.arguments.last.is_a? RestParameterNode

        *args, rest = o.arguments

        # function body -> source elements -> array
        body = o.function_body.value.value.clone

        restName = rest.value
        restOffset = args.length

        # var #{restName} = Array.prototype.slice(argument, #{restOffset});
        newCode = VarStatementNode.new([
          VarDeclNode.new(
            restName, 
            AssignExprNode.new(
              FunctionCallNode.new(
                DotAccessorNode.new(
                  DotAccessorNode.new(
                    DotAccessorNode.new(
                      ResolveNode.new("Array"),
                      "prototype"
                    ), 
                    "slice"
                  ), 
                  "call"
                ),
                ArgumentsNode.new([
                  ResolveNode.new("arguments"),
                  NumberNode.new(restOffset)
                ])
              )
            )
          )
        ])

        #puts newCode.to_sexp.to_s

        body.unshift newCode

        fxbody = FunctionBodyNode.new(SourceElementsNode.new(body))
        node = FunctionExprNode.new(o.value, fxbody, args)

        return node
      end

      def visit_FunctionDeclNode(o)
        node = fxtransform(o)
        super(node)
      end

      def visit_FunctionExprNode(o)
        node = fxtransform(o)
        super(node)
      end

      # this should never have any arguments...
      def visit_GetterPropertyNode(o)
        node = GetterProperyNode.new(o.name, fxtransform(o.value))
        super(node)
      end

      # just in case...
      def visit_SetterPropertyNode(o)
        node = SetterProperyNode.new(o.name, fxtransform(o.value))
        super(node)
      end

    end
  end
end
