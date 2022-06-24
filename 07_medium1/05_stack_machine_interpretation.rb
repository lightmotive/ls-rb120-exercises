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

    attr_reader :stdout_log
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

    attr_accessor :register
    attr_reader :stack

    def operate(operation)
      self.register = register.send(
        operation,
        stack_pop_with_validation(detail: "Operation: #{operation}")
      )

      self
    end

    def stack_pop_with_validation(detail: String.new)
      if stack.empty?
        detail = String.new(" #{detail}") unless detail.empty?
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
      api.stdout_log
    end

    protected

    def initialize_api_collaborator(print_to_stdout: false)
      @api = StackMachine.new(print_to_stdout: print_to_stdout)
    end

    private

    attr_reader :api
  end

  # Text program interpreter that uses `StackMachine` internally.
  class GeneralInterpreter
    include StackMachineCollaborator

    def initialize(print_to_stdout: true)
      initialize_api_collaborator(print_to_stdout: print_to_stdout)
    end

    def eval(program)
      reset
      self.program = program
      self.expressions = program.split

      execute(expressions.shift) until expressions.empty?
    end

    private

    attr_accessor :expressions, :program

    def reset
      api.reset
      self.program = nil
      self.expressions = []
    end

    def execute(token)
      if StackMachine::ACTIONS.include?(token)
        execute_api_send(token)
      elsif token =~ /[+-]?\d+/
        execute_api_number(token)
      else
        raise_error_with_state(BadTokenError, "#{token} is not a valid token.")
      end

      nil
    end

    def execute_api_send(token)
      api.send(token.downcase.to_sym)
    rescue MinilangError => e
      raise_error_with_state(e.class, e.message)
    end

    def execute_api_number(token)
      api.number(token.to_i)
    rescue MinilangError => e
      raise_error_with_state(e.class, e.message)
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
api = Minilang::StackMachine.new(print_to_stdout: false)
api.number(-3).push.number(5).sub.print
p api.stdout_log == ['8']

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
