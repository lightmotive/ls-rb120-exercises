# frozen_string_literal: true

class Cat
  attr_accessor :name

  COLOR = 'purple'

  def initialize(name)
    self.name = name
  end

  def greeting
    "Hello! My name is #{name} and I'm a #{COLOR} cat!"
  end
end

kitty = Cat.new('Sophie')
p kitty.greeting == "Hello! My name is Sophie and I'm a purple cat!"
