# frozen_string_literal: true

class Person
  attr_writer :secret

  def share_secret
    secret
  end

  private

  attr_reader :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'
p person1.share_secret == 'Shh.. this is a secret!'
