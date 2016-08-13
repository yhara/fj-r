require 'spec_helper'

describe FjR::TypeChecker do
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
