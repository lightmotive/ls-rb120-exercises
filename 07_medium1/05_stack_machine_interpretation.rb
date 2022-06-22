# frozen_string_literal: true

class Minilang
end

# Migrate this procedural version (RB101 Exercises, Med1.6) to OOP above:

# * Understand the problem *
# Input: string
# Output: interpreted program may or may not print values to the screen
#
# A register contains a value, a stack contains commands, and the program
# executes those commands to modify the register, perform math operations,
# and print values.
#
# Basic logic:
# - Split the command string
# - Interpret commands
#   - If command is not found in hash, it must be an integer.
# - Perform operations sequentially

require 'pp'

def raise_custom_error(error_class, message, state)
  message.concat("\n--State--\n#{state.pretty_inspect}")
  raise error_class, message
end

def validate_pop(state, detail: String.new)
  if state[:stack].size.zero?
    detail = String.new(" #{detail}") unless detail.empty?
    raise_custom_error(
      StandardError, "The stack was empty.#{detail}", state
    )
  end

  nil
end

def stack_operate!(state, operation)
  validate_pop(state, detail: "Operation: #{operation}")
  state[:register] = state[:register].send(operation, state[:stack].pop)
end

@print_to_stdout = true

COMMANDS = {
  PRINT: lambda do |state|
           output = state[:register].to_s
           state[:stdout_log].push(output)
           puts output if @print_to_stdout
         end,
  PUSH: ->(state) { state[:stack].push(state[:register]) },
  POP: lambda do |state|
    validate_pop(state)
    state[:register] = state[:stack].pop
  end,
  ADD: ->(state) { stack_operate!(state, :+) },
  SUB: ->(state) { stack_operate!(state, :-) },
  MULT: ->(state) { stack_operate!(state, :*) },
  DIV: ->(state) { stack_operate!(state, :/) },
  MOD: ->(state) { stack_operate!(state, :%) },
  default: lambda do |state, command_string|
    state[:register] = Integer(command_string)
  rescue ArgumentError
    raise_custom_error(
      ArgumentError, "#{command_string} is not a valid command.", state
    )
  end
  # Interpret integers (n) if command is not in the list above
}.freeze

def minilang_execute!(state, command_string, command)
  return COMMANDS[:default].call(state, command_string) if command.nil?

  command.call(state)

  nil
end

def minilang_iterate!(state)
  until state[:command_strings].empty?
    command_string = state[:command_strings].shift
    command = COMMANDS.fetch(command_string.to_sym, nil)
    minilang_execute!(state, command_string, command)
  end

  nil
end

def minilang(command_string)
  state = { register: 0, stack: [], command_strings: command_string.split,
            stdout_log: [] }

  begin
    minilang_iterate!(state)
  rescue StandardError => e
    return e
  end

  state
end

@print_to_stdout = false

p minilang('PRINT')[:stdout_log] == ['0']
p minilang('5 PUSH 3 MULT PRINT')[:stdout_log] == ['15']
p minilang('5 PRINT PUSH 3 PRINT ADD PRINT')[:stdout_log] == %w[5 3 8]
p minilang('5 PUSH POP PRINT')[:stdout_log] == ['5']
p minilang('3 PUSH 4 PUSH 5 PUSH PRINT ADD PRINT POP PRINT ADD PRINT')[
  :stdout_log] ==  %w[5 10 4 7]
p minilang('3 PUSH PUSH 7 DIV MULT PRINT ')[:stdout_log] == ['6']
p minilang('4 PUSH PUSH 7 MOD MULT PRINT ')[:stdout_log] == ['12']
p minilang('-3 PUSH 5 SUB PRINT')[:stdout_log] == ['8']
p minilang('6 PUSH')[:stdout_log] == []

# Further exploration 1:
# - Try writing a minilang program to evaluate and print the result of this
#   expression: (3 + (4 * 5) - 7) / (5 % 3)
p minilang('3 PUSH 5 MOD PUSH 7 PUSH 4 PUSH 5 MULT PUSH 3 ' \
  'ADD SUB DIV PRINT')[:stdout_log] == ['8']
# That's easier when one considers math order of operations. You have to work
# backwards: calculate the values, push them, then calculate the stacked values.

# ***

# Further exploration 2:
# - Add error handling.
# - Detect when program returns an error, displaying the error message.

result = minilang('6 PUSH POP POP')
p result.is_a?(StandardError)
p result.message == <<~MSG
  The stack was empty.
  --State--
  {:register=>6, :stack=>[], :command_strings=>[], :stdout_log=>[]}
MSG

result = minilang('6 PUSH ADD ADD')
p result.is_a?(StandardError)
p result.message == <<~MSG
  The stack was empty. Operation: +
  --State--
  {:register=>12, :stack=>[], :command_strings=>[], :stdout_log=>[]}
MSG

result = minilang('-3 PUSH 5 SUBTRACT PRINT')
p result.is_a?(ArgumentError)
p result.message == <<~MSG
  SUBTRACT is not a valid command.
  --State--
  {:register=>5, :stack=>[-3], :command_strings=>["PRINT"], :stdout_log=>[]}
MSG
