# frozen_string_literal: true

# Instead of inheriting from Array, we use a collaborator object so we don't
# have to override or maintain any of `Array`'s methods that are beyond
# problem domain.
# If it becomes necessary to override some methods and forward others to the
# collaborator object, one can implement the `Forwardable` module.
class FixedArray
  def initialize(size)
    @array = Array.new(size)
  end

  def [](idx)
    array.fetch(idx)
  end

  def []=(idx, value)
    self[idx]
    array[idx] = value
  end

  def to_a
    # `Array#to_a` returns `self` only if `self.is_a?(Array)`
    # Otherwise, it returns a clone of `self`.
    # In this case, implementing the latter here would be most consistent with
    # the Standard Library's `Array` behavior.
    array.clone
  end

  def inspect
    array.inspect
  end

  alias to_s inspect

  private

  attr_reader :array
end

fixed_array = FixedArray.new(5)
puts fixed_array[3].nil?
puts fixed_array.to_a == [nil] * 5

fixed_array[3] = 'a'
puts fixed_array[3] == 'a'
puts fixed_array.to_a == [nil, nil, nil, 'a', nil]

fixed_array[1] = 'b'
puts fixed_array[1] == 'b'
puts fixed_array.to_a == [nil, 'b', nil, 'a', nil]

fixed_array[1] = 'c'
puts fixed_array[1] == 'c'
puts fixed_array.to_a == [nil, 'c', nil, 'a', nil]

fixed_array[4] = 'd'
puts fixed_array[4] == 'd'
puts fixed_array.to_a == [nil, 'c', nil, 'a', 'd']
puts fixed_array.to_s == '[nil, "c", nil, "a", "d"]'

puts fixed_array[-1] == 'd'
puts fixed_array[-4] == 'c'

begin
  fixed_array[6]
  puts false
rescue IndexError
  puts true
end

begin
  fixed_array[-7] = 3
  puts false
rescue IndexError
  puts true
end

begin
  fixed_array[7] = 3
  puts false
rescue IndexError
  puts true
end
