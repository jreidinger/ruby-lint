##
# Constant: RuntimeError
# Created:  2013-04-01 18:33:55 +0200
# Platform: rbx 2.0.0.rc1
#
RubyLint::VirtualMachine.global_scope.define_constant('RuntimeError') do |klass|
  klass.inherits(RubyLint::VirtualMachine.global_constant('StandardError'))
end