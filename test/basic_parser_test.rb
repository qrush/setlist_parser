require 'test_helper'

class BasicParserTest < ActiveSupport::TestCase
  setup do
    @show = parse_show("kitty")
  end

  test "has 3 sets" do
    assert_equal 3, @show.setlists.size
    assert_equal [0, 1, 2], @show.setlists.map(&:position)
  end

  test "slots are parsed out of sets" do
    assert_equal 8,  @show.setlists.first.slots.size
    assert_equal 10, @show.setlists.second.slots.size
    assert_equal 2,  @show.setlists.third.slots.size
  end

  test "songs are parsed out of sets" do
    slots = @show.setlists.last.slots
    assert_equal ['Mosquito Valley Part I', 'Strange Times'], slots.map { |slot| slot.song.name }
  end

  test "transitions are marked" do
    slot = @show.setlists.last.slots.first
    assert_equal 'Mosquito Valley Part I', slot.song.name
    assert slot.transition?
  end

  test "notes are remembered" do
    slot1 = @show.setlists.first.slots[4]
    slot2 = @show.setlists.first.slots[5]
    slot3 = @show.setlists.second.slots[6]

    assert_equal [%{Supertramp cover}], slot1.notes
    assert_equal [%{"Purple Haze" and "Third Stone from the Sun" (Jimi Hendrix) teases}], slot2.notes
    assert_equal [%{The Beatles cover}], slot3.notes
  end

  test "covers are remembered" do
    song = @show.setlists.first.slots[4].song

    assert_equal "Bloody Well Right", song.name
    assert song.cover?
  end

  test "show can be saved" do
    @show.save!
  end
end
