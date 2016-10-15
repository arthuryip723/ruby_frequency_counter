def parse_file(file_name='file.txt')
  begin
    string = File.open(file_name, 'rb') { |file| file.read }
  rescue
    puts "File '#{file_name}' doesn't exists or has other errors."
    return
  end

  stats = Hash.new{ |hash, key| hash[key] = {count: 0, sentences: []}}

  # we need to extend this list to include more latin abbreviations in reality.
  latin_abbreviations = ['e.g.', 'i.e.', 'etc.']

  # count sentence from 1
  sentence_counter = 1
  string.split.each do |word|
    # take out some punctuations from the word
    word = word.gsub(/[",:;]/,'').downcase

    # see if it is the end of a sentence
    sentence_end = false
    if (word_end_idx = (word =~ /[.?!]$/)) && !latin_abbreviations.include?(word)
      word = word[0...word_end_idx]
      sentence_end = true
    end

    stats[word][:count] += 1
    stats[word][:sentences] << sentence_counter
    sentence_counter += 1 if sentence_end
  end

  stats.sort.to_h.each_with_index do |(word, stat), i|
    char_idx = (i % 26 + 97).chr * ((i / 26) + 1)
    tabs = word.length >= 8 ? "\t" : "\t\t"
    puts "#{char_idx}.\t#{word}#{tabs}{#{stat[:count]}: #{stat[:sentences].join(', ')}}"
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0]
    parse_file ARGV[0]
  else
    parse_file
  end
end