# frozen_string_literal: true

require 'pp'

# The OOP program above is based on this procedural version:
# https://github.com/lightmotive/ls-rb101-exercises/blob/main/11_medium1/06_stack_machine_interpretation.rb

module Minilang
  class MinilangError < StandardError; end
  class EmptyStackError < MinilangError; end
  class BadTokenError < MinilangError; end

  # Numeric stack machine.
  class StackMachine
    ACTIONS = %w[PRINT PUSH POP ADD SUB MULT DIV MOD].freeze

    attr_reader :stdout_log, :register
    attr_accessor :print_to_stdout

    alias print_to_stdout? print_to_stdout

    def initialize(print_to_stdout: false)
      self.print_to_stdout = print_to_stdout
      reset
    end

    def reset
      self.register = 0
      @stack = []
      @stdout_log = []
    end

    def print
      output = register.to_s
      stdout_log.push(output)
      puts output if print_to_stdout?

      self
    end

    def push
      stack.push(register)

      self
    end

    def pop
      self.register = stack_pop_with_validation

      self
    end

    def add
      operate(:+)
    end

    def sub
      operate(:-)
    end

    def mult
      operate(:*)
    end

    def div
      operate(:/)
    end

    def mod
      operate(:%)
    end

    def number(number)
      self.register = number

      self
    end

    private

    attr_writer :register
    attr_reader :stack

    def operate(operation)
      self.register = register.send(
        operation,
        stack_pop_with_validation(detail: "Operation: #{operation}")
      )

      self
    end

    def stack_pop_with_validation(detail: nil)
      if stack.empty?
        detail = String.new(" #{detail}") unless detail.nil? || detail.empty?
        raise_error_with_state(EmptyStackError, "The stack was empty.#{detail}")
      end

      stack.pop
    end

    def raise_error_with_state(error_class, message)
      message.concat("\n--#{self.class.name} State--")
      message.concat("\n@register=#{register}")
      message.concat("\n@stack=#{stack.pretty_inspect.strip}")
      message.concat("\n@stdout_log=#{stdout_log.pretty_inspect.strip}")

      raise error_class, message
    end
  end

  # Include in classes that use `StackMachine` as a collaborator object.
  module StackMachineCollaborator
    def stdout_log
      stack_machine.stdout_log
    end

    protected

    def initialize_stack_machine_collaborator(print_to_stdout: false)
      @stack_machine = StackMachine.new(print_to_stdout: print_to_stdout)
    end

    private

    attr_reader :stack_machine
  end

  # Text program interpreter that uses `StackMachine` internally.
  class GeneralInterpreter
    include StackMachineCollaborator

    def initialize(print_to_stdout: true)
      initialize_stack_machine_collaborator(print_to_stdout: print_to_stdout)
    end

    def eval(program, data = {})
      reset
      self.program = program % data
      self.expressions = self.program.split

      begin
        execute(expressions.shift) until expressions.empty?
      rescue MinilangError => e
        raise_error_with_state(e.class, e.message)
      end

      stack_machine.register
    end

    private

    attr_accessor :expressions, :program

    def reset
      stack_machine.reset
      self.program = nil
      self.expressions = []
    end

    def execute(token)
      if StackMachine::ACTIONS.include?(token)
        stack_machine.send(token.downcase.to_sym)
      elsif integer?(token)
        stack_machine.number(token.to_i)
      else
        raise BadTokenError, "#{token} is not a valid token."
      end

      nil
    end

    def integer?(token)
      token =~ /[+-]?\d+/
    end

    def raise_error_with_state(error_class, message)
      message.concat("\n--#{self.class.name} State--")
      message.concat("\n@program=#{program}")
      message.concat("\n@expressions=#{expressions.pretty_inspect.strip}")

      raise error_class, message
    end
  end
end

# Test helper
def general_interpreter_test(program)
  interpreter = Minilang::GeneralInterpreter.new(print_to_stdout: false)

  begin
    interpreter.eval(program)
    interpreter
  rescue Minilang::MinilangError => e
    e
  end
end

p general_interpreter_test('PRINT').stdout_log == ['0']
p general_interpreter_test('5 PUSH 3 MULT PRINT').stdout_log == ['15']
p general_interpreter_test('5 PRINT PUSH 3 PRINT ADD PRINT').stdout_log == %w[5 3 8]
p general_interpreter_test('5 PUSH POP PRINT').stdout_log == ['5']
p general_interpreter_test('3 PUSH 4 PUSH 5 PUSH PRINT ADD PRINT POP PRINT ADD PRINT').stdout_log == %w[5 10 4 7]
p general_interpreter_test('3 PUSH PUSH 7 DIV MULT PRINT ').stdout_log == ['6']
p general_interpreter_test('4 PUSH PUSH 7 MOD MULT PRINT ').stdout_log == ['12']
p general_interpreter_test('-3 PUSH 5 SUB PRINT').stdout_log == ['8']
# StackMachine example that replicates program above
stack_machine = Minilang::StackMachine.new(print_to_stdout: false)
stack_machine.number(-3).push.number(5).sub.print
p stack_machine.stdout_log == ['8']

p general_interpreter_test('6 PUSH').stdout_log == []

# Further exploration 1:
# - Try writing a general_interpreter_test program to evaluate and print the result of this
#   expression: (3 + (4 * 5) - 7) / (5 % 3)
p general_interpreter_test('3 PUSH 5 MOD PUSH 7 PUSH 4 PUSH 5 MULT PUSH 3 ADD SUB DIV PRINT').stdout_log == ['8']
# That's easier when one considers math order of operations. You have to work
# backwards: calculate the values, push them, then calculate the stacked values.

# ***

result = general_interpreter_test('6 PUSH POP POP')
p result.is_a?(Minilang::EmptyStackError)
p result.message == <<~MSG.strip
  The stack was empty.
  --Minilang::StackMachine State--
  @register=6
  @stack=[]
  @stdout_log=[]
  --Minilang::GeneralInterpreter State--
  @program=6 PUSH POP POP
  @expressions=[]
MSG

result = general_interpreter_test('6 PUSH ADD ADD')
p result.is_a?(Minilang::EmptyStackError)
p result.message == <<~MSG.strip
  The stack was empty. Operation: +
  --Minilang::StackMachine State--
  @register=12
  @stack=[]
  @stdout_log=[]
  --Minilang::GeneralInterpreter State--
  @program=6 PUSH ADD ADD
  @expressions=[]
MSG

result = general_interpreter_test('-3 PUSH 5 SUBTRACT PRINT')
p result.is_a?(Minilang::BadTokenError)
puts result.message == <<~MSG.strip
  SUBTRACT is not a valid token.
  --Minilang::GeneralInterpreter State--
  @program=-3 PUSH 5 SUBTRACT PRINT
  @expressions=["PRINT"]
MSG

# Convert C to F using `Minilang::GeneralInterpreter`.
class CentigradeToFahrenheit
  PROGRAM = '5 PUSH %<degrees_c>d PUSH 9 MULT DIV PUSH 32 ADD PRINT'

  def initialize
    @interpreter = Minilang::GeneralInterpreter.new(print_to_stdout: false)
  end

  def convert(degrees_c)
    interpreter.eval(PROGRAM, { degrees_c: degrees_c })
  end

  private

  attr_reader :interpreter
end

c_to_f = CentigradeToFahrenheit.new
p c_to_f.convert(100) == 212
p c_to_f.convert(0) == 32
p c_to_f.convert(-40) == -40
