# frozen_string_literal: true

require 'csv'
require 'yaml'

# hangman game
class Game
  def initialize(name)
    @words_file = File.open('lib/google-10000-english.csv')
    @words = @words_file.readlines
    @word = ''
    @word = @words.sample.chomp until @word.length.between?(5, 12)
    @chances = 7
    @clues = Array.new(@word.length, '_')
    @right_guesses = []
    @wrong_guesses = []
    @name = name
  end

  def save_game
    puts 'Enter your save name: '
    file_name = gets.chomp
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    File.open("./saved_games/#{file_name}.yml", 'w') do |file|
      state = { word: @word, clues: @clues, right_guesses: @right_guesses, wrong_guesses: @wrong_guesses, chances: @chances }
      file.write(state.to_yaml)
    end
  end

  def load_state(file_name)
    state = YAML.load(File.open("./saved_games/#{file_name}.yml"))
    @word = state[:word]
    @clues = state[:clues]
    @right_guesses = state[:right_guesses]
    @wrong_guesses = state[:wrong_guesses]
    @chances = state[:chances]
  end

  def load_game
    puts 'Enter the save you want to load: '
    file_name = gets.chomp
    if File.exist?("./saved_games/#{file_name}.yml")
      load_state(file_name)
      display_guesses
    else
      puts 'Your save is not here!'
    end
  end

  def generate_random_word
    @word = ''
    @word = @words.sample until @word.length.between?(5, 12)
    @word
  end

  def display_guesses
    puts "Right guesses: #{@right_guesses.sort.join ','}"
    puts "Wrong guesses: #{@wrong_guesses.sort.join ','}"
    puts @clues.join('')
  end

  def handle_input(input)
    chars = @word.split('')
    case input
    when 'save'
      save_game
    when 'load'
      load_game
    else
      if check_guess(chars, input)
        @right_guesses.push(input)
      else
        @wrong_guesses.push(input)
        @chances -= 1
      end
    end
  end

  def player_input
    character = ''
    loop do
      puts "Enter a character please:\n"
      character = gets.chomp
      break if [ 'save', 'load' ].include?(character)
      break unless @right_guesses.include?(character) || @wrong_guesses.include?(character) || character.length > 1

      puts 'You have already tried this character' if @wrong_guesses.include?(character)
      puts 'Invalid input' if character.length > 1
    end
    character
  end

  def update_result(pos)
    pos.each { |index| @clues[index] = @word[index] }
  end

  def check_guess(chars, guess)
    pos = []
    chars.each_with_index { |char, index| pos.push(index) if char == guess }
    # pos is used to reveal the position of characters
    update_result(pos)
  end

  def check_win
    @clues.join('') == @word
  end

  def game_play
    
    until @chances.zero?
      break if check_win
      input = player_input
      handle_input(input)
      display_guesses
      puts 'Only one try left, be careful with your next choice' if @chances == 1
      puts check_win
    end
    puts check_win ? 'Congratulations, you win' : "You lose, the answer is #{@word}"
  end
end

test = Game.new('player')
test.game_play
