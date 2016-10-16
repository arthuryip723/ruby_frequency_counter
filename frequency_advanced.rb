require 'active_support/core_ext/string/inflections'
require 'verbs'

# we want to make "teacher's" become "teacher", but we don't want "he's" become "he".
PRONOUNS = ["he's", "she's", "it's"]

def parse_file(file_name='file.txt')
  begin
    content = File.open(file_name, 'rb') { |file| file.read }
  rescue
    puts "File '#{file_name}' doesn't exists or has other errors."
    return
  end

  # :merged_words is for storing differet forms of the verb when after merging
  # :deleted is for marking the word being merged and thus deleted
  stats = Hash.new{ |hash, key| hash[key] = {count: 0, sentences: [], deleted: false, merged_words: []}}

  # take out some marks from the word that we don't care about
  words = content.split.map{ |word| word.gsub(/[",:;()]/, '') }

  # count sentence from 1
  sentence_counter = 1
  words.each_with_index do |word, i|
    word = word.downcase

    # see if it is the end of a sentence with the helper method
    sentence_end = false
    if is_sentence_end?(word, words, i)
      word = word[0..-2]
      sentence_end = true
    end

    # take care of situation like "teachers'"
    word = word[0..-2] if word[-1] == "'"

    # take care of situation like "teacher's"
    word = word[0..-3] if word[-2..-1] == "'s" && !PRONOUNS.include?(word)

    # sigularize words
    word = word.singularize

    # add to the stats
    stats[word][:count] += 1
    stats[word][:sentences] << sentence_counter

    sentence_counter += 1 if sentence_end
  end

  # try to merge words of the same verb into one entry
  stats.each do |word, stat|
    forms = get_word_forms(word)
    forms.each do |form|
      merge_words(word, form, stats) if stats.key?(form)
    end
  end

  # print result
  stats.reject{ |word, stat| stat[:deleted] }.sort.to_h.each_with_index do |(word, stat), i|
    word += "(#{stat[:merged_words].join(', ')})" if stat[:merged_words].length > 0
    
    char_idx = (i % 26 + 97).chr * ((i / 26) + 1)
    
    tabs = case (word).length
      when 0..7 then "\t\t\t"
      when 8..15 then "\t\t"
      else "\t"
    end

    puts "#{char_idx}.\t#{word}#{tabs}{#{stat[:count]}: #{stat[:sentences].join(', ')}}"
  end
end

# The following methods refers to the wikipedia page about finding the sentence boundary
# https://en.wikipedia.org/wiki/Sentence_boundary_disambiguation

# The standard 'vanilla' approach to locate the end of a sentence:[clarification needed]

# (a) If it's a period, it ends a sentence.
# (b) If the preceding token is in the hand-compiled list of abbreviations, then it doesn't end a sentence.
# (c) If the next token is capitalized, then it ends a sentence.

# I translated (c) into: if the next token starts with a lower case letter, it doesn't end a sentence.

# this list needs to be extended in reality.
ABBREVIATIONS = ['e.g.', 'i.e.', 'etc.']

def is_sentence_end?(word, words, current_index)
  # if it doesn't end with .?!
  return false if !(word =~ /[.?!]$/)

  # if it is in the abbreviation list
  return false if ABBREVIATIONS.include?(word)

  # if the next token starts with a lower case letter
  next_word = words[current_index + 1]
  if next_word
    first_char = next_word[0]
    return false if first_char >= 'a' && first_char <= 'z'
  end

  true
end

# Return differen forms of a word
# For the word "write", it returns "writes", "writing", "wrote", "written"
def get_word_forms(word)
  word_sym = word.to_sym
  [ 
    Verbs::Conjugator.conjugate(word_sym, :tense => :present, :person => :third, :aspect => :habitual),
    Verbs::Conjugator.conjugate(word_sym, :tense => :present, :aspect => :progressive)[3..-1],
    Verbs::Conjugator.conjugate(word_sym, :tense => :past, :aspect => :perfective),
    Verbs::Conjugator.conjugate(word_sym, :tense => :present, :aspect => :perfect)[4..-1]
  ]
end

# This method merge different forms of a same verb, e.g. "write", "writes", "writing", "wrote", "written".
# It merges the stat of w2 into that of w1 and mark w2 as deleted.
def merge_words(w1, w2, stats)
  stats[w1][:count] += stats[w2][:count]
  stats[w1][:sentences].concat(stats[w2][:sentences]).sort!
  (stats[w1][:merged_words] << w2).sort!
  stats[w2][:deleted] = true
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0]
    parse_file ARGV[0]
  else
    parse_file
  end
end