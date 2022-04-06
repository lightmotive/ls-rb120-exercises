# frozen_string_literal: true

class Cat
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def greeting
    "Hello! My name is #{name} :-)"
  end

  def greet
    puts greeting
  end
end
