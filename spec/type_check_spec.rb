require 'spec_helper'

describe FjR::TypeChecker do
  # TODO: instance variable name must not be the same as superclass's
  # TODO: type of this
  # TODO: check arity/argtype of super()

  context "class definition" do
    it "cyclic inheritance" do
      expect {
        TC.check <<-EOD
          class A extends B { A(){ super(); } }
          class B extends C { B(){ super(); } }
          class C extends A { C(){ super(); } }
          new A();
        EOD
      }.to raise_error(TC::CyclicInheritance)
    end
  end

  context "field definition" do
    #it "may be typed self" do
    #  expect {
    #    TC.check <<-EOD
    #      class A extends Object {
    #        A a;
    #        A(A a_){ super(); this.a = a_; }
    #      }
    #      ?? TODO: how could I instantiate A?
    #    EOD
    #  }.to raise_error(TODO)
    #end
  end

  context "ctor definition" do
    it "ctor should recieve args for all fields" do
      expect {
        TC.check <<-EOD
          class A extends Object {
            Object o;
            A(){ super(); }
          }
          new A();
        EOD
      }.to raise_error(TC::ArityError)
    end
  end

  context "method definition" do
    it "must return declared type" do
      expect {
        TC.check <<-EOD
          class A extends Object {
            A(){ super(); }
            Object bad_method(){ return new A(); }
          }
          new A();
        EOD
      }.to raise_error(TC::ReturnTypeError)
    end

    it "may return self type" do
      result_type = TC.check <<-EOD
        class A extends Object {
          A(){ super(); }
          A ok_method(){ return new A(); }
        }
        new A().ok_method();
      EOD
      expect(result_type).to eq("A")
    end

    it "may mutually recurse over classes" do
      result_type = TC.check <<-EOD
        class A extends Object {
          A(){ super(); }
          A foo(){ return new B().bar(); }
        }
        class B extends Object {
          B(){ super(); }
          A bar(){ return new A().foo(); }
        }
        new A().foo();
      EOD
      expect(result_type).to eq("A")
    end
  end

  context "ctor call" do
    it "must pass expected number of arguments" do
      expect {
        TC.check <<-EOD
          new Object(new Object())
        EOD
      }.to raise_error(TC::ArityError)
    end

    it "must give arguments of expected type" do
      expect {
        TC.check <<-EOD
          class A extends Object { A(){ super(); } }
          class B extends Object {
            A my_a;
            B(A a){ super(); this.my_a = a; }
          }
          new B(new Object());
        EOD
      }.to raise_error(TC::ArgTypeError)
    end
  end

  context "method call" do
    it "may invoke a method defined in the superclass" do
      result_type = TC.check <<-EOD
        class A extends Object {
          A(){ super(); }
          Object foo(){ return new Object(); }
        }
        class B extends A {
          B(){ super(); }
        }
        new B().foo();
      EOD
      expect(result_type).to eq("Object")
    end

    it "should check arity" do
      expect {
        TC.check <<-EOD
          class A extends Object {
            A(){ super(); }
            Object foo(Object x){ return x; }
          }
          new A().foo();
        EOD
      }.to raise_error(TC::ArityError)
    end

    it "should check param type" do
      expect {
        TC.check <<-EOD
          class A extends Object {
            A(){ super(); }
            A foo(A x){ return x; }
          }
          new A().foo(new Object());
        EOD
      }.to raise_error(TC::ArgTypeError)
    end

    it "may pass an instance of a subclass" do
      TC.check <<-EOD
        class A extends Object {
          A(){ super(); }
          Object foo(Object x){ return x; }
        }
        new A().foo(new A());
      EOD
    end
  end

  context "field reference" do
    it "may refer a field defined in the superclass" do
      result_type = TC.check <<-EOD
        class A extends Object {
          Object obj;
          A(Object obj_){ super(); this.obj = obj_; }
        }
        class B extends A { B(Object o){ super(o); } }
        new B(new Object()).obj;
      EOD
      expect(result_type).to eq("Object")
    end
  end

  context "variable reference" do
    it "should be typed as its type" do
      TC.check <<-EOD
        class A extends Object {
          A(){ super(); }
          Object foo(Object o){ return o; }
        }
        class B extends Object {
          B(){ super(); }
          Object bar(Object o){ return new A().foo(o); }
        }
        new B().bar(new Object());
      EOD
    end
  end

  context "casting"

  context "override"
  # TODO: overriding method of superclass is allowed
  #   - but must have the same type
end
