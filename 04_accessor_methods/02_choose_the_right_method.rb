# frozen_string_literal: true

class Person
  attr_accessor :name, :phone_number
  private :phone_number
end

person1 = Person.new
person1.name = 'Jessica'
person1.phone_number = '0123456789'
puts person1.name
