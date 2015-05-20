require 'pry'

module Guessr
  class Menu
    def initialize
      @player = nil
      @game = nil
    end

    def choose_player
      puts "Welcome Player 1!"
      puts "Please enter your name: "
      result = gets.chomp
      until result =~ /^\w+$/
        puts "Please enter a name you doofus: "
        result = gets.chomp
      end
      @player = Player.find_or_create_by(name: result)
      # puts "Please choose a player: "
      # Player.find_each do |p|
      #   puts "#{p.id} -> #{p.name}"
      # end
      # result = gets.chomp
      # until result =~ /^\d+$/
      #   puts "Please choose one of the listed ids."
      #   result = gets.chomp
      # end
      # @player = Player.find(result.to_i)
    end

    def choose_game
      puts "Start a new game (1) or resume an existing game (2)?"
      result = gets.chomp
      until result =~ /^[12]$/
        puts "Please choose new game (1) or existing game (2). Doofus."
        result = gets.chomp
      end
      if result.to_i == 1
        @game = @player.games.create(answer: rand(100),
                                     guess_count: 0)
      else
        @player.games.where(finished: false).find_each do |game|
          puts "#{game.id} => Last Guess: #{game.last_guess}, Guess Count: #{game.guess_count}"
        end
        puts "Please choose one of the numbered games: "
        result = gets.chomp
        until result =~ /^\d+$/
          puts "I said pick a *numbered* game dummy."
          result = gets.chomp
        end
        @game = Game.find(result)
      end
    end

    def run
      welcome
      choose_player
      scoreboard_start
      while play_again?
        choose_game
        @game.play
      end
      puts "Thanks for playing!"
    end

    def play_again?
      puts "Would you like to play again? (y or n)"
      result = gets.chomp
      until result =~ /^[yn]$/i
        puts "You have to choose yes (y) or no (n)."
        result = gets.chomp
      end
      result.downcase == 'y'
    end

    def welcome
      puts "\n\n"
      puts "Welcome to the guessing game!"
      puts "At any time, you may exit the game by pressing (q) to Quit."
      puts "\n\n"
    end

    def scoreboard_start
      puts "Would you like to look at the scoreboard? (y/n)"
      choice = gets.chomp
      until choice =~ /^[yn]$/i
        puts "Your input was not recognized!"
        puts "Please enter Yes (y) or No (n)!"
        choice = gets.chomp
      end
      scoreboard_type(choice)
    end


    def scoreboard_type(choice)
      if choice.downcase == 'y'
        puts "Which scoreboard would you like to look at?"
        puts "1: Highest Total Scores"
        puts "2: Highest Average Score per Game"
        response = gets.chomp
        until response =~ /^[12]$/
          puts "Your input was not recognized!"
          puts "Please enter '1' or '2'!"
          response = gets.chomp
        end
        if response == '1'
          scoreboard_high
          if scoreboard_again?
            scoreboard_type('y')
          else
            puts "Let's play a game!"
          end
        else
          scoreboard_avg
          if scoreboard_again?
            scoreboard_type('y')
          else
            puts "Let's play a game!"
          end
        end
      else
        puts "Let's play a game!"
      end
    end

    def scoreboard_again?
      puts "Would you like to look at another scoreboard? (y/n)"
      choice = gets.chomp
      until choice =~ /^[yn]$/i
        puts "Your input was not recognized!"
        puts "Please enter Yes (y) or No (n)!"
        choice = gets.chomp
      end
      choice.downcase == 'y'
    end

    def scoreboard_high
      puts "** Highest Total Scores **"
      Player.all.order(score: :desc).each do |x|
        puts "#{x.name} -- #{x.score}"
      end
    end

    def scoreboard_avg
      player_averages = []
      Player.all.each do |x|
        finished_games = x.games.where(finished: true).count
        total_score = x.score
        avg_score = total_score / finished_games
        player_averages << [avg_score, x]
      end
      puts "** Highest Averge Score per Game **"
      player_averages.sort.reverse.each do |avg_score, player|
        puts "#{player.name} -- #{avg_score}"
      end
    end
  end
end





