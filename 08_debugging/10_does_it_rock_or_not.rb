# frozen_string_literal: true

class AuthenticationError < Exception; end

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

  class NoScore; end

  class Score
    def self.for_term(term)
      positive = SearchEngine.count(%("#{term} rocks"), API_KEY).to_f
      negative = SearchEngine.count(%("#{term} is not fun"), API_KEY).to_f

      positive / (positive + negative)
    rescue Exception
      # Line 31 is the first problem: one shouldn't rescue `Exception` here
      # because it catches all errors.
      NoScore
    end
  end

  def self.find_out(term)
    score = Score.for_term(term)

    case score
    when NoScore
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
