# frozen_string_literal: true

class Banner
  def initialize(message, max_width: nil)
    @max_width = max_width
    self.message = message
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  attr_reader :message, :max_width
  attr_accessor :message_for_banner

  def message=(message)
    @message = message

    self.message_for_banner = message_max_width(message)
  end

  def message_max_width(message)
    return message if max_width.nil?

    "#{message.slice(0, max_width - 3)}..."
  end

  def horizontal_rule
    "+-#{'-' * message_for_banner.length}-+"
  end

  def empty_line
    "| #{' ' * message_for_banner.length} |"
  end

  def message_line
    "| #{message_for_banner} |"
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

banner = Banner.new('To boldly go where no one has gone before.', max_width: 15)
p(banner.to_s == <<~OUTPUT.strip
  +-----------------+
  |                 |
  | To boldly go... |
  |                 |
  +-----------------+
OUTPUT
 )
