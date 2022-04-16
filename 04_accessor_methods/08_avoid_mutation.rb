# frozen_string_literal: true

class Person
  def initialize(name)
    @name = name
  end

  def name
    @name.dup
  end
end

person1 = Person.new('James')
puts person1.name.reverse!
puts person1.name
