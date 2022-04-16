# frozen_string_literal: true

class Person
  def name=(full_name)
    @first_name, @last_name = split_name(full_name)
  end

  def name
    "#{@first_name} #{@last_name}"
  end

  private

  def split_name(full_name)
    full_name.split
  end
end

person1 = Person.new
person1.name = 'John Doe'
puts person1.name
