# frozen_string_literal: true

require_relative '02_create_the_class'

kitty = Cat.new('Sophie')
puts kitty.greeting
kitty.greet

kitty.name = 'Luna'
kitty.greet
kitty.walk
