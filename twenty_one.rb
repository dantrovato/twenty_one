require 'pry'

class Participant
  attr_reader :cards_held, :deck

  def initialize(deck)
    @cards_held = []
    @deck = deck
  end

  def calculate_total(cards)
    sum = 0

    cards.each do |value|
      if value == "ace"
        sum += 11
      elsif value.to_i == 0
        sum += 10
      else
        sum += value.to_i
      end
    end

    values.select { |value| value == 'ace' }.count.times do
      sum -= 10 if sum > 21
    end

    sum
  end

  def total
    calculate_total(values)
  end

  def hit
    # binding.pry
    cards_held << deck.deal_card
    puts "your cards now are now #{cards_held} worth #{total} "
  end

  def values
    cards_held.map { |card| card[1] } # => ex. ["ace", "7"]
  end

  def bust?
    total > 21
  end
end

class Player < Participant
  def move
    answer = nil
    loop do
      if total < 21
        puts "Would you like to hit or stay? (h/s) "

        loop do
          answer = gets.chomp
          break if %w(h s).include?(answer)
          puts "Sorry. Invalid answer. 'h' or 's'."
        end

        if answer == 'h'
          hit
        else
          puts "You stayed."
          break
        end
      elsif total == 21
        puts "Perfect score!"
        break
      else
        puts "you've gone bust!"
        break
      end
    end
  end
end

class Dealer < Participant
  def move
    loop do
      if total < 17
        cards_held << deck.deal_card
      end
      break if total >= 17
    end
    puts "Dealer total is #{total}"
  end

  def initial_total
    [values[0]]
  end
end

class Deck
  SUITS = %w(hearts clubs diamonds spades)
  VALUES = %w(2 3 4 5 6 7 8 9 10 jack queen king ace)

  attr_reader :cards

  def initialize
    @cards = SUITS.product(VALUES).shuffle
  end

  def deal_card
    cards.shift
  end

  def to_s
    cards
  end
end

class Game
  attr_reader :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new(deck)
    @dealer = Dealer.new(deck)
  end

  def display_welcome_message
    puts "Welcome to 21!"
  end

  def display_goodbye_message
    puts "Thanks for playing."
  end

  def deal_cards
    2.times do
      player.cards_held << deck.deal_card
      dealer.cards_held << deck.deal_card
    end
  end

  def display_cards
    puts "Your cards are #{player.cards_held}, for a total of: #{player.total}"
    # => ex. [["diamonds", "3"], ["hearts", "6"]]
    puts "Dealer cards are #{dealer.cards_held[0]},
    worth #{dealer.calculate_total(dealer.initial_total)} and ??"
  end

  def declare_winner
    if player.bust?
      puts "You busted. Dealer wins."
    elsif dealer.bust?
      puts "Dealer busted. Player wins."
    elsif player.total > dealer.total
      puts "Player wins."
    elsif player.total < dealer.total
      puts "Dealer wins."
    else
      puts "It's a tie!"
    end
  end

  def start
    system 'clear'
    display_welcome_message
    deal_cards
    display_cards
    player.move
    dealer.move
    declare_winner
    display_goodbye_message
  end
end

Game.new.start
