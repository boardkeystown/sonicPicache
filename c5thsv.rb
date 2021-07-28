##| @author boardkeystown
##| Circle of fifths from note and scale ring generator v1.0
##| ----------------------------------------------------------------------------------

##| Note on use:
##| Since midi is 0 to 127 ish... These functions work best when using notes at the
##| start of the midi scale e.g. :c0, :db0, :d0 .... then move it down a octave
##| so that it is at octave -1. For example :c0-12
##| For a glance at the midi notes see
##| https://sonic-pi.mehackit.org/exercises/en/01-introduction/02-play-a-melody.html


##| Functions


##| #this will print out the sonic pi notes, midi, and index of a scale ring
##| #where x is the scale
define :printNotes do |x|
  k = 0
  for i in x
    puts  note_info(i).to_s +  " midi: "+ i.to_s + " index #{k}"; k=k+1
  end
  puts "Len: " + x.length.to_s
end

##| returns a ring of fifths based on a
##| starting note and a scale.
##| IDK if this works 100% right with every scale
define :makeFifths do |startNote, use_scale_|
  count_ = 0
  out = []
  ##| build a scale and store the first note of it
  tempScale = (scale startNote, use_scale_)
  nextNote = tempScale[0]
  out.push(nextNote)
  ##| We need 11 more notes for a circle of 5ths
  ##| to build it we just need to grab to dominate note and
  ##| and keep building up the scale (see)
  ##| https://www.musical-u.com/learn/how-to-use-circle-fifths/
  ##| https://www.musictheory.net/lessons/23
  while count_ < 11
    dom = tempScale.length/2
    dom = tempScale.length - dom
    nextNote = tempScale[dom]
    out.push(nextNote)
    tempScale = (scale nextNote, use_scale_)
    count_ = count_ + 1
  end
  out = out.ring
  return out
end

## | This is a mess but all it does to 'normalize' the circle of 5ths is
## | set the notes to the same octave
define :normalize do |notes_in, target_oct|
  #table of midi notes
  note_table = [[0,    1,    2,  3,    4,   5,   6,   7,   8,   9,  10,  11],
                [12,  13,   14, 15,   16,  17,  18,  19,  20,  21,  22,  23],
                [24,  25,   26, 27,   28,  29,  30,  31,  32,  33,  34,  35],
                [36,  37,   38, 39,   40,  41,  42,  43,  44,  45,  46,  47],
                [48,  49,   50, 51,   52,  53,  54,  55,  56,  57,  58,  59],
                [60,  61,   62, 63,   64,  65,  66,  67,  68,  69,  70,  71],
                [72,  73,   74, 75,   76,  77,  78,  79,  80,  81,  82,  83],
                [84,  85,   86, 87,   88,  89,  90,  91,  92,  93,  94,  95],
                [96,  97,   98, 99,  100, 101, 102, 103, 104, 105, 106, 107],
                [108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119],
                [120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131]]
  notes_out = []
  notes_in.each do |note_|
    done = false
    #search the table for the a note at a index
    for i in note_table
      for j in i
        if j == note_ then
          #adjust the note to match the octave
          index = note_table.index(i)
          while target_oct < index
            index = index - 1
            note_ = note_ - 12
          end
          while target_oct > index
            index = index + 1
            note_ = note_ + 12
          end
          notes_out.push(note_)
          done = true
          break
        end
      end
      if done == true then break end
    end
  end
  notes_out = notes_out.ring
  return notes_out
end

## | combines the later functions for easier use
define :makeC5ths do |note_,use_scale_,oct_|
  out_ = makeFifths note_, use_scale_
  out_ = normalize out_,oct_
  return out_
end

##| Example Use

##| Pick a scale and a note
use_scale = :major_pentatonic
##| use_scale = :blues_major
##| use_scale = :mixolydian
##| use_scale = :major
myNote = :g0-12

x = (scale myNote, use_scale)

##| Just to show what a scale looks like to compare to c5ths
puts note_info(x[0]).to_s + " scale!"; puts
printNotes x

##| Use this website to see if the c5ths is correct
##| https://apps.musedlab.org/aqwertyon/theory/G-0-major-pentatonic

puts
puts "C5ths b4 making 'normal'"; puts
out = makeFifths myNote, use_scale
printNotes out

puts
puts "C5ths after making 'normal'";puts
out = normalize out,2
printNotes out

##| Just a example of how you could use set
##| To run these heavy functions once to get a
##| Circle of 5ths (I hope you get the idea)

##| out = makeC5ths myNote, use_scale, 2
##| set :c5ths, out
##| printNotes get(:c5ths)



#play all 12 fifths
live_loop :foo do
  ##| stop
  ##| use_octave 1
  use_synth :piano
  play out.tick, amp: 0.3
  sleep 1
end

#easy to make a quick grove
#Don't even care what notes these are it's just cool
#they all sound ok together
live_loop :bar do
  stop
  use_octave 1
  use_synth :piano
  w = (knit 0.25,4, 0.5,1, 0.25,1)
  n = (ring 0,3,2,2,1,5,11)
  tick
  play out[n.look], amp: 0.3
  sleep w.look
end
