# frozen_string_literal: true

require 'pp'

class MinilangError < StandardError; end
class BadTokenError < MinilangError; end
class EmptyStackError < MinilangError; end

# Stack Machine interpreter.
class Minilang
  ACTIONS = %w[PRINT PUSH POP ADD SUB MULT DIV MOD].freeze

  attr_reader :stdout_log

  def initialize(print_to_stdout: true)
    @print_to_stdout = print_to_stdout
    reset
  end

  def eval(program)
    reset
    self.program = program
    self.expressions = program.split

    execute(expressions.shift) until expressions.empty?
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
    validate_pop
    self.register = stack.pop

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

  def integer(integer)
    self.register = integer

    self
  end

  private

  attr_accessor :register, :expressions, :program
  attr_reader :stack, :print_to_stdout

  alias print_to_stdout? print_to_stdout

  def reset
    self.program = nil
    self.expressions = []
    self.register = 0
    @stack = []
    @stdout_log = []
  end

  def execute(token)
    if ACTIONS.include?(token)
      send(token.downcase.to_sym)
    elsif token =~ /[+-]?\d+/
      integer(token.to_i)
    else
      raise_error_with_state(BadTokenError, "#{token} is not a valid token.")
    end

    nil
  end

  def operate(operation)
    validate_pop(detail: "Operation: #{operation}")
    self.register = register.send(operation, stack.pop)

    self
  end

  def validate_pop(detail: String.new)
    if stack.size.zero?
      detail = String.new(" #{detail}") unless detail.empty?
      raise_error_with_state(EmptyStackError, "The stack was empty.#{detail}")
    end

    nil
  end

  # rubocop:disable Metrics/AbcSize
  def raise_error_with_state(error_class, message)
    message.concat("\n--#{self.class.name} State--")
    message.concat("\n@program=#{program}")
    message.concat("\n@expressions=#{expressions.pretty_inspect.strip}")
    message.concat("\n@register=#{register}")
    message.concat("\n@stack=#{stack.pretty_inspect.strip}")
    message.concat("\n@stdout_log=#{stdout_log.pretty_inspect}")
    raise error_class, message
  end
  # rubocop:enable Metrics/AbcSize
end

# The OOP program above is based on this procedural version:
# https://github.com/lightmotive/ls-rb101-exercises/blob/main/11_medium1/06_stack_machine_interpretation.rb

def minilang_test(program)
  minilang = Minilang.new(print_to_stdout: false)

  begin
    minilang.eval(program)
    minilang
  rescue MinilangError => e
    e
  end
end

p minilang_test('PRINT').stdout_log == ['0']
p minilang_test('5 PUSH 3 MULT PRINT').stdout_log == ['15']
p minilang_test('5 PRINT PUSH 3 PRINT ADD PRINT').stdout_log == %w[5 3 8]
p minilang_test('5 PUSH POP PRINT').stdout_log == ['5']
p minilang_test('3 PUSH 4 PUSH 5 PUSH PRINT ADD PRINT POP PRINT ADD PRINT').stdout_log == %w[5 10 4 7]
p minilang_test('3 PUSH PUSH 7 DIV MULT PRINT ').stdout_log == ['6']
p minilang_test('4 PUSH PUSH 7 MOD MULT PRINT ').stdout_log == ['12']
p minilang_test('-3 PUSH 5 SUB PRINT').stdout_log == ['8']
# "Exec API" example that replicates program above
minilang = Minilang.new(print_to_stdout: false)
minilang.integer(-3)
minilang.push
minilang.integer(5)
minilang.sub
minilang.print
p minilang.stdout_log == ['8']

p minilang_test('6 PUSH').stdout_log == []

# Further exploration 1:
# - Try writing a minilang_test program to evaluate and print the result of this
#   expression: (3 + (4 * 5) - 7) / (5 % 3)
p minilang_test('3 PUSH 5 MOD PUSH 7 PUSH 4 PUSH 5 MULT PUSH 3 ADD SUB DIV PRINT').stdout_log == ['8']
# That's easier when one considers math order of operations. You have to work
# backwards: calculate the values, push them, then calculate the stacked values.

# ***

result = minilang_test('6 PUSH POP POP')
p result.is_a?(EmptyStackError)
p result.message == <<~MSG
  The stack was empty.
  --Minilang State--
  @program=6 PUSH POP POP
  @expressions=[]
  @register=6
  @stack=[]
  @stdout_log=[]
MSG

result = minilang_test('6 PUSH ADD ADD')
p result.is_a?(EmptyStackError)
p result.message == <<~MSG
  The stack was empty. Operation: +
  --Minilang State--
  @program=6 PUSH ADD ADD
  @expressions=[]
  @register=12
  @stack=[]
  @stdout_log=[]
MSG

result = minilang_test('-3 PUSH 5 SUBTRACT PRINT')
p result.is_a?(BadTokenError)
puts result.message == <<~MSG
  SUBTRACT is not a valid token.
  --Minilang State--
  @program=-3 PUSH 5 SUBTRACT PRINT
  @expressions=["PRINT"]
  @register=5
  @stack=[-3]
  @stdout_log=[]
MSG
