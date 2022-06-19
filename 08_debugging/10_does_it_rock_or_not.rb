# frozen_string_literal: true

class AuthenticationError < StandardError; end

# A mock search engine
# that returns a random number instead of an actual count.
class SearchEngine
  def self.count(_query, api_key)
    raise AuthenticationError, 'API key is not valid.' unless valid?(api_key)

    rand(200_000)
  end

  def self.valid?(key)
    key == 'LS1A'
  end
end

module DoesItRock
  API_KEY = 'LS1A2'

  class NoScore
    def self.===(other)
      self == other
    end
  end

  class Score
    def self.for_term(term)
      positive = SearchEngine.count(%("#{term} rocks"), API_KEY).to_f
      negative = SearchEngine.count(%("#{term} is not fun"), API_KEY).to_f

      positive / (positive + negative)
    rescue AuthenticationError
      NoScore
    end
  end

  def self.find_out(term)
    score = Score.for_term(term)

    case score
    when NoScore
      # Line 39 above is the next problem:
      # NoScore doesn't respond to `===`, which is how `case` tests whether
      # patterns (`when [...]`) match an object (`score`).
      # In this case, the simplest solution would be to implement `self.===` in
      # `NoScore`. Perhaps we'd want `===` to be an instance method, but since
      # this is a simple mock-up with no additional implementation details,
      # we'll start with a class method.
      "No idea about #{term}..."
    when 0...0.5
      "#{term} is not fun."
    when 0.5
      "#{term} seems to be ok..."
    else
      "#{term} rocks!"
    end
  rescue Exception => e
    e.message
  end
end

# Example (your output may differ)

puts DoesItRock.find_out('Sushi')       # Sushi seems to be ok...
puts DoesItRock.find_out('Rain')        # Rain is not fun.
puts DoesItRock.find_out('Bug hunting') # Bug hunting rocks!
