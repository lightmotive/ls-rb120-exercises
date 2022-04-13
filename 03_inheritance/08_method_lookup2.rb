# frozen_string_literal: true

class Animal
end

class Cat < Animal
end

class Bird < Animal
end

cat1 = Cat.new
puts Cat.ancestors
cat1.color # NoMethodError
