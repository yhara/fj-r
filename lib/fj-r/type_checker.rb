require 'tsort'

module FjR
  class TypeChecker
    class Error < StandardError; end
    class ArityError < Error; end
    class ArgTypeError < Error; end
    class NameError < Error; end
    class ReturnTypeError < Error; end
    class CyclicInheritance < Error; end

    # For test
    def self.check(str)
      ast = FjR::Parser.new.parse(str)
      program = FjR::Program.new(ast)
      FjR::TypeChecker.new(program).check
    end

    # @param program [FjR::Program]
    def initialize(program)
      @program = program
      @fclasses = @program.fclasses
    end

    def check
      check_superclasses!(@program.fclasses)
      @program.fclasses.each{|k, v| check_fclass(v)}
      type_expr!(@program.expr, {})
    end

    private

    class FClassesCyclicChecker
      include TSort

      def initialize(fclasses)
        @fclasses = fclasses
      end

      def tsort_each_node(&block)
        @fclasses.each_value(&block)
      end

      def tsort_each_child(fclass, &block)
        return if fclass.parent == :noparent # Object
        if (parent = @fclasses[fclass.parent])
          block.call(parent)
        else
          raise NameError, format("unknown class %s", fclass.parent)
        end
      end
    end

    def check_superclasses!(fclasses)
      FClassesCyclicChecker.new(fclasses).tsort
    rescue TSort::Cyclic
      raise CyclicInheritance
    end

    def check_fclass(fclass)
      fclass.fmethods.each do |_, meth|
        env = meth.params.map{|param|
          [param.name, param.type_name]
        }.to_h
        type_expr!(meth.body_expr, env)

        if meth.body_expr.type != meth.ret_type
          raise ReturnTypeError, format(
            "%s#%s is declared to return %s but returns %s",
            fclass.name, meth.name, meth.ret_type, meth.body_expr.type)
        end
      end
    end

    def type_expr!(e, env)
      case e
      when Ast::CastExpr
        TODO
      when Ast::VarRef
        e.type = env.fetch(e.name)
      when Ast::FieldRef
        type_expr!(e.expr, env)
        e.type = fclass(e.expr.type).field(e.name)
      when Ast::MethodCall
        type_expr!(e.expr, env)
        method = fclass(e.expr.type).method(e.name)
        if e.args.length != method.arity
          raise ArityError, format("%p takes %d arguments but gave %d",
                                   method, method.arity, e.args.length)
        end
        arg_types = e.args.map{|arg|
          type_expr!(arg, env)
          arg.type
        }
        method.params.zip(e.args) do |param, arg_expr|
          type_expr!(arg_expr, env)
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
          type_expr!(arg_expr, env)
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
