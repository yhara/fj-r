module FjR
  class Program
    class Error < StandardError; end
    class ArityError < Error; end
    class NameError < Error; end
    class SyntaxError < Error
      def self.misplaced(node)
        new("misplaced #{node}")
      end
    end

    def initialize(ast)
      raise TypeError unless ast.is_a?(Ast::Program)

      obj_ctor = FCtor.new("Object", [], [], [])
      @fclasses = {
        "Object" => FClass.new("Object", :noparent, obj_ctor, {}, {})
      }

      ast.class_defs.each do |x|
        @fclasses[x.name] = parse_class_def(x)
      end
      @expr = ast.expr
    end
    attr_reader :fclasses   # {String => FClass}
    attr_reader :expr       # Ast::Node

    private

    def parse_class_def(class_def)
      raise SyntaxError.misplaced(class_def) unless class_def.is_a?(Ast::ClassDef)

      ctor = nil
      fields = {}
      methods = {}
      class_def.member_defs.each do |x|
        case (m = parse_member_def(x))
        when FCtor 
          if ctor
            raise SyntaxError, "class #{class_def.name} can have only one constructor" 
          elsif m.name != class_def.name
            raise SyntaxError.misplaced(m)
          end
          ctor = m
        when FField
          if fields.key?(m.name)
            raise SyntaxError, format("field name %s of class %s duplicated",
                                      m.name, class_def.name)
          end
          fields[m.name] = m
        when FMethod 
          if methods.key?(m.name)
            raise SyntaxError, format("method name %s of class %s duplicated",
                                      m.name, class_def.name)
          end
          methods[m.name] = m
        else
          raise "must not happen"
        end
      end

      if ctor.nil?
        raise SyntaxError, format("missing ctor of class %s", class_def.name)
      elsif ctor.arity != fields.length
        raise ArityError, format("ctor of class %s must receive %d argument(s)",
                                 class_def.name, fields.length)
      end

      return FClass.new(class_def.name, class_def.parent_name,
                        ctor, fields, methods)
    end

    def parse_member_def(member_def)
      case member_def
      when Ast::CtorDef
        return FCtor.new(
          member_def.name,
          member_def.params,
          member_def.super_params,
          member_def.field_assigns
        )
      when Ast::FieldDef
        return FField.new(
          member_def.field_name,
          member_def.type_name,
        )
      when Ast::MethodDef
        return FMethod.new(
          member_def.method_name,
          member_def.ret_type_name,
          member_def.params,
          member_def.body_expr
        )
      else
        raise SyntaxError.misplaced(member_def)
      end
    end

    class FClass
      extend Props
      props :name, # String
            :parent_name, # String or :noparent
            :ctor,
            :ffields, # {String => FField},
            :fmethods # {String => FMethod}

      # Will be set by TypeChecker#set_superclasses!
      # :noparent is set for Object
      attr_accessor :parent

      def init
        raise "ctor is nil" if @ctor.nil?
      end

      def field(name)
        if (f = @ffields[name])
          return f
        else
          raise NameError, format("unknown field %s of class %s",
                                  name, @name)
        end
      end

      # returns FMethod defined on this class or its ancestors
      def find_method(name, start = @name)
        if (m = @fmethods[name])
          return m
        else
          if @parent == :noparent
            raise NameError, format("unknown method %s of class %s",
                                    name, start)
          else
            return @parent.find_method(name, start)
          end
        end
      end
    end

    class FField
      extend Props
      props :name, :type
    end

    class FCtor
      extend Props
      props :name, :params, :super_params, :field_assigns

      def arity
        @params.length
      end
    end

    class FMethod
      extend Props
      props :name, :ret_type, :params, :body_expr

      def arity
        @params.length
      end
    end
  end
end
