# frozen_string_literal: true

class Person
  attr_accessor :phone_number
  private :phone_number=

  def initialize(number)
    self.phone_number = number
    # That is the best approach in Ruby 2.7+ because the convention enables
    # easy future attribute writer method replacement in the future.

    # Earlier versions would need to use `attr_reader :phone_number` above,
    # and `@phone_number = number` in this method because those versions don't
    # allow `self.[method]` on private methods.
  end
end

person1 = Person.new(1_234_567_899)
puts person1.phone_number

person1.phone_number = 9_987_654_321 # => Expect NoMethodError exception
puts person1.phone_number
