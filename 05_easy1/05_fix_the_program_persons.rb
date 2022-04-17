# frozen_string_literal: true

class Person
  def initialize(first_name, last_name)
    self.first_name = first_name
    self.last_name = last_name
  end

  def first_name=(value)
    @first_name = value.capitalize
  end

  def last_name=(value)
    @last_name = value.capitalize
  end

  def to_s
    "#{@first_name} #{@last_name}"
  end
end

person = Person.new('john', 'doe')
puts person

person.first_name = 'jane'
person.last_name = 'smith'
puts person
