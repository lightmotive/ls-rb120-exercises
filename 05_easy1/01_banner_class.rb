# frozen_string_literal: true

class Banner
  def initialize(message)
    @message = message
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  attr_reader :message

  def horizontal_rule
    "+-#{'-' * message.length}-+"
  end

  def empty_line
    "| #{' ' * message.length} |"
  end

  def message_line
    "| #{message} |"
  end
end

banner = Banner.new('To boldly go where no one has gone before.')
p(banner.to_s == <<~OUTPUT.strip
  +--------------------------------------------+
  |                                            |
  | To boldly go where no one has gone before. |
  |                                            |
  +--------------------------------------------+
OUTPUT
 )

banner = Banner.new('')
p(banner.to_s == <<~OUTPUT.strip
  +--+
  |  |
  |  |
  |  |
  +--+
OUTPUT
 )
