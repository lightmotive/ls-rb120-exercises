# frozen_string_literal: true

class Animal
  attr_reader :color

  def initialize(color)
    @color = color
  end
end

class Cat < Animal
end

class Bird < Animal
end

cat1 = Cat.new('Black')
cat1.color
# Method Lookup Path through `color` invocation:
# 1. Cat
# 2. Animal
