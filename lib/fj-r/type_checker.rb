module FjR
  class TypeChecker
    class Error < StandardError; end
    class ArityError < Error; end
    class ArgTypeError < Error; end
    class NameError < Error; end

    # @param program [FjR::Program]
    def initialize(program)
      @program = program
      @fclasses = @program.fclasses
    end

    def check
      @program.fclasses.each(&method(:check_fclass))
      type_expr!(@program.expr, {})
    end

    private

    def check_fclass(fclass)
      #最初に、各フィールドとメソッドの型を整理しないといけない？
      #TODO
    end

    def type_expr!(e, env)
      case e
      when Ast::CastExpr
        TODO
      when Ast::VarRef
        e.type = env.fetch(e.name)
      when Ast::FieldRef
        type_expr!(e.expr)
        e.type = fclass(e.expr.type).field(e.name)
      when Ast::MethodCall
        type_expr!(e.expr)
        method = fclass(e.expr.type).method(e.name)
        if e.args.length != method.arity
          raise ArityError, format("%p takes %d arguments but gave %d",
                                   method, method.arity, e.args.length)
        end
        arg_types = e.args.map{|arg|
          type_expr!(arg)
          arg.type
        }
        method.params.zip(e.args) do |param, arg_expr|
          type_expr!(arg_expr)
          if param.type_name != arg_expr.type
            raise ArgTypeError, format("%s expected but got %s (%p)",
                                       param.type_name, arg_expr.type, arg_expr)
          end
        end
        e.type = method.ret_type
      when Ast::NewObj
        fklass = fclass(e.type_name)
        ctor = fklass.ctor
        if e.args.length != ctor.arity
          raise ArityError, format("constructor of %s takes %d arguments but gave %d",
                                   fklass.name, ctor.arity, e.args.length)
        end
        ctor.params.zip(e.args) do |param, arg_expr|
          type_expr!(arg_expr)
          if param.type_name != arg_expr.type
            raise ArgTypeError, format("%s expected but got %s (%p)",
                                       param.type_name, arg_expr.type, arg_expr)
          end
        end
        e.type = fklass.name
      end
    end

    def fclass(name)
      if (fclass = @fclasses[name])
        return fclass
      else
        raise NameError, format("unknown class %s", name)
      end
    end
  end
end
