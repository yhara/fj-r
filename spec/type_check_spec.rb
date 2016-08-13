require 'spec_helper'

describe FjR::TypeChecker do
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
      }.to raise_error(FjR::Program::ArityError)
    end
  end

  context "invalid ctor call" do
    it "too many arguments" do
      expect {
        TC.check <<-EOD
          new Object(new Object())
        EOD
      }.to raise_error(TC::ArityError)
    end

    it "argument type mismatch" do
      expect {
        TC.check <<-EOD
          class A extends Object { A(){ super(); } }
          class B extends Object {
            A my_a;
            B(A a){ super(); this.my_a = a; }
          }
          new Object(new Object())
        EOD
      }.to raise_error(TC::ArityError)
    end
  end
end
