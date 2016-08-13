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
end
