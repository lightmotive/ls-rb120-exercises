# frozen_string_literal: true

require_relative 'walkable'

class Cat
  include Walkable

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
