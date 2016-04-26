$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'setlist_parser'

require 'yaml'
require 'minitest/autorun'

require 'active_support'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :venue, force: true do |t|
  end

  create_table :shows, force: true do |t|
    t.integer :venue_id
    t.datetime :performed_at
    t.text :raw_setlist
    t.string :notes
  end

  create_table :setlists, force: true do |t|
    t.integer :show_id
    t.integer :position
    t.string :name
  end

  create_table :slots, force: true do |t|
    t.integer :setlist_id
    t.integer :song_id
    t.integer :position
    t.boolean :transition
    t.string :notes
  end

  create_table :songs, force: true do |t|
    t.string :name
    t.boolean :cover
  end
end

class Venue < ActiveRecord::Base
end

class Show < ActiveRecord::Base
  belongs_to :venue
  has_many :setlists
  serialize :notes, Array
end

class Setlist < ActiveRecord::Base
  belongs_to :show
  has_many :slots
  has_many :songs, through: :slots
end

class Slot < ActiveRecord::Base
  belongs_to :setlist
  belongs_to :song
  serialize :notes, Array
end

class Song < ActiveRecord::Base
end

class ActiveSupport::TestCase
  def parse_show(name, options = {})
    raw_setlist = File.read("test/fixtures/raw_setlists/#{name}.txt")
    SetlistParser.parse({raw_setlist: raw_setlist, venue: nil, performed_at: Date.today}.merge(options))
  end
end
