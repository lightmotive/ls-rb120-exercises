# frozen_string_literal: true

class Person
  attr_accessor :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'
p person1.secret == 'Shh.. this is a secret!'
