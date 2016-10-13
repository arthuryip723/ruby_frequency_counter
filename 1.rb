def parse(file_name='file.txt')
  string = File.open(file_name, 'rb') { |file| file.read }

  stats = Hash.new{ |hash, key| hash[key] = {count: 0, sentences: []}}

  # we need to extend this list.
  latin_abbreviations = ['e.g.', 'i.e.', 'etc.']
  # punctuations = '.,?!:;'.split('')
  ending_punctuations = '.?!'.split('')

  # pronouns_with_s = ["he's", "she's", "it's"]

  # count sentence from 1
  sentence_count = 1

  string.split.each do |word|
    # take out double quotes from the word
    word = word.gsub(/[",:;]/,'').downcase
    sentence_end = false
    # if (ending_idx = (word =~ /[.,?!:;]$/)) && !latin_abbreviations.include?(word)
    # take out punctuations and see if it is the end of a sentence
    if (ending_punctuations.include?(word[-1])) && !latin_abbreviations.include?(word)
      word = word[0...-1]
      sentence_end = true
    end

    # take care of situation like students'
    # word = word[0...-1] if word[-1] == "'"
    # take care of situation like gop's
    # word = word[0...-2] if word.end_with?("'s") && !pronouns_with_s.include?(word)
    # word = word.singularize
    stats[word][:count] += 1
    stats[word][:sentences] << sentence_count
    sentence_count += 1 if sentence_end
  end

  i = 0
  stats.sort.to_h.each do |k, v|
    char_idx = (i % 26 + 97).chr * ((i / 26) + 1)
    tabs = k.length >= 8 ? "\t" : "\t\t"
    puts "#{char_idx}.\t#{k}#{tabs}{#{v[:count]}: #{v[:sentences].join(', ')}}"
    i += 1
  end
end

=begin
Thoughts about improving the program
1, Right now the program doesn't take care of treating the single form and the plural form as the same word.
2, Right now the program doesn't take care of verb forms. e.g. in "I've written" and "I write", "written" and "write" should be regarded as the same word.
But in "written material" and "I write" they should be different.
=end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0]
    parse ARGV[0]
  else
    parse
  end
end