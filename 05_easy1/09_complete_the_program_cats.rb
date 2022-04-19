# frozen_string_literal: true

class Pet
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end
end

class Cat < Pet
  attr_reader :fur_color

  def initialize(name, age, fur_color)
    super(name, age)

    @fur_color = fur_color
  end

  def to_s
    "My cat #{name} is #{age} years old and has #{fur_color} fur."
  end
end

pudding = Cat.new('Pudding', 7, 'black and white')
butterscotch = Cat.new('Butterscotch', 10, 'tan and white')

p "#{pudding}\n#{butterscotch}" == <<~OUTPUT.strip
  My cat Pudding is 7 years old and has black and white fur.
  My cat Butterscotch is 10 years old and has tan and white fur.
OUTPUT
