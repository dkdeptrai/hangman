# frozen_string_literal: true

require 'csv'

# hangman game
class Game
  def initialize(name)
    @words_file = File.open('lib/google-10000-english.csv')
    @words = @words_file.readlines
    @word = ''
    @word = @words.sample.chomp until @word.length.between?(5, 12)
    @result = Array.new(@word.length, '_')
    @right_guesses = []
    @wrong_guesses = []
    @name = name
  end

  def test
    p @words
  end

  def generate_random_word
    @word = ''
    @word = @words.sample until @word.length.between?(5, 12)
    @word
  end

  def display_guesses
    puts "Right guesses: #{@right_guesses.sort.join ','}"
    puts "Wrong guesses: #{@wrong_guesses.sort.join ','}"
    puts @result.join('')
  end

  def player_choice
    puts 'Enter a character please: '
    character = ''
    loop do
      character = gets.chomp
      break unless @right_guesses.include?(character) || @wrong_guesses.include?(character)

      puts 'You have already tried this character'
    end
    character
  end

  def update_result(pos)
    pos.each { |index| @result[index] = @word[index] }
  end

  def check_guess(chars, guess)
    pos = []
    chars.each_with_index { |char, index| pos.push(index) if char == guess }
    update_result(pos)
  end

  def check_win
    @result.join('') == @word
  end

  def game_play
    p @word
    p @word.length
    chars = @word.split('')
    chances = 7
    until chances.zero? || check_win
      guess = player_choice
      if !check_guess(chars, guess).empty?
        @right_guesses.push(guess)
      else
        @wrong_guesses.push(guess)
        chances -= 1
      end
      display_guesses
      puts "Only one try left, be careful with your next choice" if chances == 1
    end
    puts check_win ? 'Congratulations, you win' : "You lose, the answer is #{@word}"
  end
end

test = Game.new('player')
test.game_play
