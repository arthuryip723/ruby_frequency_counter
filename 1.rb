string = File.open('file.txt', 'rb') { |file| file.read }

stats = Hash.new{ |hash, key| hash[key] = {count: 0, sentence: []}}

# # need to take care of .;!
# string.split(/[.,?!:;]/).each.with_index do |sentence, i|
#   # puts sentence
#   sentence.split.each do |word|
#     # word = word.tr('"', '').chomp
#     # edge case could be gates', tom's,
#     word = (word.gsub(/["]/,'')).downcase
#     next if word.length == 0
#     stats[word][:count] += 1
#     stats[word][:sentence] << (i + 1)
#   end
# # end

sentence_count = 1

# we need to extend this list.
latin_abbreviations = ['e.g.', 'i.e.', 'etc.']

string.split.each do |word|
  # word = (word.gsub(/"|'|'s/,'')).downcase
  word = word.tr('"','').downcase
  sentence_end = false
  if (ending_idx = (word =~ /[.,?!:;]$/)) && !latin_abbreviations.include?(word)
    word = word[0...-1]
    sentence_end = true
  end

  # take care of situation like students'
  word = word[0...-1] if word[-1] == "'"
  # word = word.singularize
  stats[word][:count] += 1
  stats[word][:sentence] << sentence_count
  # sentence_count += 1 if word.end_with?('.')
  sentence_count += 1 if sentence_end
end

i = 0
stats.sort.to_h.each do |k, v|
  char_idx = (i % 26 + 97).chr * ((i / 26) + 1)
  tabs = k.length >= 8 ? "\t" : "\t\t"
  puts "#{char_idx}.\t#{k}#{tabs}{#{v[:count]}: #{v[:sentence].join(', ')}}"
  i += 1
end