require 'spec_helper'

describe 'Building module definitions' do
  describe 'scoping definitions' do
    it 'processes a global module' do
      defs    = build_definitions('module Example; end')
      example = defs.lookup(:const, 'Example')

      example.is_a?(ruby_object).should == true

      example.type.should == :const
      example.name.should == 'Example'
    end

    it 'processes a nested module' do
      code = <<-CODE
module First
  module Second
  end
end
      CODE

      defs  = build_definitions(code)
      first = defs.lookup(:const, 'First')

      first.is_a?(ruby_object).should == true

      defs.lookup(:const, 'Second').nil?.should == true

      first.lookup(:const, 'Second') \
        .is_a?(ruby_object) \
        .should == true
    end

    it 'processes a global and nested module' do
      code = <<-CODE
module First
  module Second
  end
end

module Third
end
      CODE

      defs  = build_definitions(code)
      first = defs.lookup(:const, 'First')

      first.lookup(:const, 'Second') \
        .is_a?(ruby_object) \
        .should == true

      # Due to "First" and "Third" being defined in the same scope the "Third"
      # constant is available inside the "First" module.
      first.lookup(:const, 'Third') \
        .is_a?(ruby_object) \
        .should == true

      first.lookup(:const, 'Second') \
        .lookup(:const, 'Third') \
        .is_a?(ruby_object) \
        .should == true

      defs.lookup(:const, 'Third') \
        .is_a?(ruby_object) \
        .should == true
    end
  end

  describe 'redefining modules' do
    it 'updates a module when it is redefined' do
      code = <<-CODE
module First
end

module First
  def example
  end
end
      CODE

      defs = build_definitions(code)

      defs.lookup(:const, 'First') \
        .lookup(:instance_method, 'example') \
        .is_a?(ruby_method) \
        .should == true
    end

    it 'should not pollute modules in a different namespace' do
      code = <<-CODE
module Foo
  module Parser
  end

  module Bar
    module Parser
      def foo
      end
    end
  end
end
      CODE

      defs = build_definitions(code)

      first = defs.lookup(:const, 'Foo')
        .lookup(:const, 'Parser')

      second = defs.lookup(:const, 'Foo')
        .lookup(:const, 'Bar')
        .lookup(:const, 'Parser')

      first.should_not == second

      first.lookup(:instance_method, 'foo').is_a?(ruby_object).should  == false
      second.lookup(:instance_method, 'foo').is_a?(ruby_object).should == true
    end
  end

  describe 'including modules' do
    it 'includes a module' do
      code = <<-CODE
module First
  def example
  end
end

module Second
  include First
end
      CODE

      defs = build_definitions(code)

      defs.lookup(:const, 'Second') \
        .lookup(:instance_method, 'example') \
        .is_a?(ruby_method) \
        .should == true
    end

    it 'extends a module' do
      code = <<-CODE
module First
  def example
  end
end

module Second
  extend First
end
      CODE

      defs = build_definitions(code)

      defs.lookup(:const, 'Second') \
        .lookup(:method, 'example') \
        .is_a?(ruby_method) \
        .should == true
    end

    it 'includes a module using a constant path' do
      code = <<-CODE
module First
  module Second
    def example
    end
  end
end

module Third
  include First::Second
end
      CODE

      defs = build_definitions(code)

      defs.lookup(:const, 'Third') \
        .lookup(:instance_method, 'example') \
        .is_a?(ruby_method) \
        .should == true
    end

    it 'includes a module using a variable' do
      code = <<-CODE
module First
  def example
  end
end

module Second
  first = First
  include first
end
      CODE

      defs = build_definitions(code)

      defs.lookup(:const, 'Second') \
        .lookup(:instance_method, 'example') \
        .is_a?(ruby_method) \
        .should == true
    end
  end
end
