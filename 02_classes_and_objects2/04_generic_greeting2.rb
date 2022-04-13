# frozen_string_literal: true

class Cat
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def self.generic_greeting
    "Hello! I'm a #{self}!" # #{name} would also work here.
  end

  def personal_greeting
    "Hello! My name is #{name}!"
  end
end

kitty = Cat.new('Sophie')

p Cat.generic_greeting == "Hello! I'm a #{Cat}!"
p kitty.personal_greeting == 'Hello! My name is Sophie!'
