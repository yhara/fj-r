module FjR
  class Ast
    class Program < Ast
      def initialize(class_defs, expr)
        @class_defs, @expr = class_defs, expr
      end
    end

    class ClassDef < Ast
      def initialize(name, parent_name, defs)
        @name, @parent_name, @defs = name, parent_name, defs
      end
    end

    class CtorDef < Ast
      def initialize(name, params, super_params, field_assigns)
        @name, @params, @super_params, @field_assigns =
          name, params, super_params, field_assigns
      end
    end

    class FieldAssign < Ast
      def initialize(this_name, param_name)
        @this_name, @param_name = this_name, param_name
      end
    end

    class FieldDef < Ast
      def initialize(type_name, field_name)
        @type_name, @field_name = type_name, field_name
      end
    end

    class MethodDef < Ast
      def initialize(ret_type_name, method_name, params, body_expr) 
        @ret_type_name, @method_name, @params, @body_expr =
          ret_type_name, method_name, params, body_expr
      end
    end

    class Param < Ast
      def initialize(type_name, name)
        @type_name, @name = type_name, name
      end
    end

    class CastExpr < Ast
      def initialize(type_name, expr)
        @type_name, @expr = name, expr
      end
    end

    class VarRef < Ast
      def initialize(name)
        @name = name
      end
    end

    class FieldRef < Ast
      def initialize(expr, name)
        @expr, @name = expr, name
      end
    end

    class MethodCall < Ast
      def initialize(expr, name, args)
        @expr, @name, @args = expr, name, args
      end
    end

    class NewObj < Ast
      def initialize(type_name, args)
        @type_name, @args = type_name, args
      end
    end
  end
end
