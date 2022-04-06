# frozen_string_literal: true

class Cat
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def greeting
    "Hello! My name is #{name} :-)"
  end
end
