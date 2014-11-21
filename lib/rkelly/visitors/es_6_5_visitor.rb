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

        # could get fancy and check if the variable is actually used.
        # seems like most of the time it should be used, though.
        
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


      def visit_ArrowFunctionExprNode(o)
        # arrow function expression.  shortcut for function expression
        # but also binds `this`.  Body may be a body or an expression.
        #
        # (args) => { ... } -> function(args) {}.bind(this)
        # (args) => expr -> function(args) { return expr }.bind(this)
        #

        fx = nil
        args = o.arguments
        fxbody = nil

        if o.expression?

          fxbody = FunctionBodyNode.new(
            SourceElementsNode.new([
              ReturnNode.new(
                o.function_body
              )
            ])
          )

        else

          fxbody = o.function_body

        end

        node = FunctionExprNode.new("function", fxbody, args)


        # only need to bind if `this` is used in the function.
        must_bind = false
        fxbody.each {|x|
          must_bind = true if x.is_a? ThisNode
        }

        
        node = FunctionCallNode.new(
          DotAccessorNode.new(
              node,
              "bind"
            ),
            ArgumentsNode.new([
              ThisNode.new("this")
            ])
        ) if must_bind

        node.accept(self)

      end

    end
  end
end
