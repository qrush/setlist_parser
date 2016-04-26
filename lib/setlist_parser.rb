require "setlist_parser/version"
require "setlist_parser/parser"

module SetlistParser
  def self.parse(options)
    Parser.new(options).parse
  end
end
