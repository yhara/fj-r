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
      return FjR::TypeChecker.new(program).check
    end

    # @param program [FjR::Program]
    def initialize(program)
      @program = program
      @fclasses = @program.fclasses
    end

    # Set types to each expressions
    # @return [String] type of the result of the program
    def check
      set_superclasses!(@program.fclasses)
      @program.fclasses.each{|k, v| check_fclass(v)}
      type_expr!(@program.expr, {})
      return @program.expr.type
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
        return if fclass.parent_name == :noparent # Object
        if (c = @fclasses[fclass.parent_name])
          block.call(c)
        else
          raise TypeChecker::NameError, format("unknown class %s",
                                               fclass.parent_name)
        end
      end
    end

    def set_superclasses!(fclasses)
      begin
        FClassesCyclicChecker.new(fclasses).tsort
      rescue TSort::Cyclic
        raise CyclicInheritance
      end
      fclasses.each_value do |fclass|
        if fclass.parent_name == :noparent
          fclass.parent = :noparent  #Object
        else
          fclass.parent = fclasses.fetch(fclass.parent_name)
        end
      end
    end

    def check_fclass(fclass)
      # ctor
      if fclass.ctor.arity != fclass.n_fields
        raise ArityError, format(
          "ctor of class %s must receive %d arg(s) but receives %d",
          fclass.name, fclass.n_fields, fclass.ctor.arity)
      end

      # methods
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
        e.type = fclass(e.expr.type).find_field(e.name).type
      when Ast::MethodCall
        type_expr!(e.expr, env)
        method = fclass(e.expr.type).find_method(e.name)
        if e.args.length != method.arity
          raise ArityError, format("%p takes %d arguments but gave %d",
                                   method, method.arity, e.args.length)
        end
        method.params.zip(e.args) do |param, arg_expr|
          type_expr!(arg_expr, env)
          if !subtype?(arg_expr.type, param.type_name)
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
          if !subtype?(arg_expr.type, param.type_name)
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

    # Return true when t1 <: t2
    def subtype?(t1, t2)
      return true if t1 == t2
      fclass(t2) # Check existance of class t2
      return fclass(t1).descendant_of?(t2)
    end
  end
end
