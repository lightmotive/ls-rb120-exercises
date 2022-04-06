# frozen_string_literal: true

class Cat
  def self.generic_greeting
    puts "Hello! I'm a cat!"
  end
end

Cat.generic_greeting

# Further exploration:
kitty = Cat.new
kitty2 = kitty.class.new
kitty2.class.generic_greeting
