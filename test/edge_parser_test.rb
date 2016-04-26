require 'test_helper'

class EdgeParserTest < ActiveSupport::TestCase
  test "more than one note is supported" do
    show = parse_show("candy")
    slot = show.setlists.first.slots.first

    assert_equal ["Mahnkali's Pocket Watch tease", "With John from Broccoli Samurai on guitar"], slot.notes
  end

  test "parts of songs are parsed" do
    show = parse_show("origami")
    show.save!

    slot1 = show.setlists.first.slots.first
    slot2 = show.setlists.last.slots.first

    assert_equal "Complex", slot1.song.name
    assert_equal "Complex Part II", slot2.song.name
  end

  test "songs aren't repeated" do
    assert_nothing_raised do
      2.times do |n|
        show = parse_show("origami", performed_at: n.days.ago)
        show.save!
      end
    end
  end

  test "multiple encores" do
    show = parse_show("eondon")
    assert_equal ['SET I', 'ENCORE I', 'ENCORE II'], show.setlists.map(&:name)
  end

  test "transition can be before notes" do
    show = parse_show("warren")
    slot = show.setlists.first.slots[1]

    assert_equal "All In", slot.song.name
    assert slot.transition?
  end

  test "bookmarks can be used on more than one song" do
    show = parse_show("breathe")
    slot = show.setlists.first.slots[1]

    assert_equal "Short Skirt, Long Jacket", slot.song.name
    assert_equal ["First time played"], slot.notes

    slot = show.setlists.first.slots[3]

    assert_equal "Lets Get It On", slot.song.name
    assert_equal ["First time played"], slot.notes
  end

  test "NOTES does not get parsed as a song" do
    show = parse_show("breathe")
    assert show.setlists.map(&:slots).flatten.none? { |slot| slot.song.name == "NOTES" }
  end

  test "unmatched notes get saved on the show" do
    show = parse_show("breathe")
    assert_equal 'Played by Nick on drums', show.notes.last
  end
end
