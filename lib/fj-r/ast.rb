module FjR
  class Ast
    class Node
      extend Props
    end

    class Program < Node
      props :class_defs, :expr
    end

    class ClassDef < Node
      props :name, :parent_name, :member_defs
    end

    class CtorDef < Node
      props :name, :params, :super_params, :field_assigns
    end

    class FieldAssign < Node
      props :this_name, :param_name
    end

    class FieldDef < Node
      props :type_name, :field_name
    end

    class MethodDef < Node
      props :ret_type_name, :method_name, :params, :body_expr
    end

    class Param < Node
      props :type_name, :name
    end

    class CastExpr < Node
      props :type_name, :expr
      attr_accessor :type
    end

    class VarRef < Node
      props :name
      attr_accessor :type
    end

    class FieldRef < Node
      props :expr, :name
      attr_accessor :type
    end

    class MethodCall < Node
      props :expr, :name, :args
      attr_accessor :type
    end

    class NewObj < Node
      props :type_name, :args
      attr_accessor :type
    end
  end
end
