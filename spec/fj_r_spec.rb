require 'spec_helper'

describe FjR do
  it "should parse source code" do
    ast = FjR::Parser.new.parse("
      class T extends Object {
        T() { super(); }
        Object foo(Object x) {
          return x;
        }
      }
      new T().foo(new Object())
    ")
    FjR::Program.new(ast)
  end
end
