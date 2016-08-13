require 'spec_helper'

TC = FjR::TypeChecker

describe FjR::TypeChecker do
  def check(str)
    ast = FjR::Parser.new.parse(str)
    program = FjR::Program.new(ast)
    FjR::TypeChecker.new(program).check
  end

  context "invalid ctor call" do
    it "too many arguments" do
      expect {
        check <<-EOD
          new Object(new Object())
        EOD
      }.to raise_error(TC::ArityError)
    end
  end
end
