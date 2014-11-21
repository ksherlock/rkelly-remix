require File.dirname(__FILE__) + "/helper"

class ArrowFunctionExprNodeTest < NodeTestCase
  def test_to_sexp
    body = FunctionBodyNode.new(SourceElementsNode.new([]))
    node = ArrowFunctionExprNode.new(body, [])
    assert_sexp([:arrow_func, nil, [], [:func_body, []]], node)
  end

  def test_to_sexp_with_args
    body = FunctionBodyNode.new(SourceElementsNode.new([]))
    node = ArrowFunctionExprNode.new(body, [ParameterNode.new('a')])
    assert_sexp([:arrow_func, nil, [[:param, 'a']], [:func_body, []]],
                node)
  end

  def test_to_sexp_with_expr
    expr = ResolveNode.new('a')
    node = ArrowFunctionExprNode.new(expr, [ParameterNode.new('a')])
    assert_sexp([:arrow_func, nil, [[:param, 'a']], [:resolve, 'a']],
                node)
  end


end
