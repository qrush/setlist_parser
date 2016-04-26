class SetlistParser::Parser
  BOOKMARKS = /([#%\*\^\$\-&†]+|Note:)/i

  def initialize(options = {})
    @show = Show.new(options)
    @setlist = nil
    @notes_by_bookmark = {}
    @slots_with_bookmarks = []
    @songs = {}
  end

  def parse
    lines.each_with_index do |line, index|
      case line
      when /^(SET|ENCORE)/i
        @setlist = @show.setlists.build(position: @show.setlists.size, name: line)
      when /^#{BOOKMARKS}/
        @notes_by_bookmark[$1] = $'.strip
      when /^(.+) >/
        build_slot($1, transition: true)
      else
        build_slot(line)
      end
    end

    build_slot_metadata
    @show.notes = build_show_notes
    @show
  end

  private

    def lines
      @show.raw_setlist.split("\n").map(&:strip).select { |line| line.present? && line !~ /NOTES/i }
    end

    def build_slot(line, options = {})
      slot = @setlist.slots.build(options.merge(position: @setlist.slots.size, notes: ['Array driver is broken']))
      slot.notes.pop
      name = parse_name(line)

      if song = (@songs[name] || Song.find_by_name(name))
        slot.song = song
      else
        @songs[name] ||= slot.build_song(name: name)
      end

      line.scan(BOOKMARKS).each do |(bookmark)|
        @slots_with_bookmarks << [bookmark, slot]
      end
    end

    def parse_name(name)
      name.gsub(BOOKMARKS, "").strip
    end

    def build_slot_metadata
      @notes_by_bookmark.each do |bookmark, note|
        @slots_with_bookmarks.each do |(slotted_bookmark, slot)|
          if bookmark == slotted_bookmark
            slot.notes << note

            if slot.song.new_record? && note =~ /cover/i
              slot.song.cover = true
            end
          end
        end
      end
    end

    def build_show_notes
      @notes_by_bookmark.map do |bookmark, note|
        if @slots_with_bookmarks.none? { |(slotted_bookmark), _| bookmark == slotted_bookmark }
          note
        else
          nil
        end
      end.compact
    end
end
