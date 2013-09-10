class Deck
  # No accessors.  Deck properties should only be accessed through instance methods.
  def initialize
    @deck = []

    ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'].each do |face|
      @deck << Card.new(face, 'Diamonds')
      @deck << Card.new(face, 'Spades')
      @deck << Card.new(face, 'Clubs')
      @deck << Card.new(face, 'Hearts')
    end
  end

  def shuffle
    @deck.shuffle!
  end

  def deal
    @deck.pop
  end
end

class Player
  attr_reader :game_value

  def initialize
    @hand = []
    @game_value = 0
  end

  def take_card(card)
    @hand << card
    @game_value = 0 #reset to zero when card is taken until the hand is played.
  end

  def best_value
    sum = 0
    aces = 0
    @hand.each do |card|
      value = 0
      if card.face == 'A'
        value = 11
        aces += 1
      elsif card.face == 'J' || card.face == 'Q' || card.face == 'K'
        value = 10
      else
        value = card.face.to_i
      end
      sum += value
    end

    while sum > 21 and aces > 0
      sum -= 10
      aces -= 1
    end

    sum
  end
end

class Gambler < Player
  attr_reader :name

  def initialize(name)
    @name = name
    @hand = []
    @game_value = 0 # game_value is 0 by default unless assigned from play_hand
  end

  def show_hand
    puts "#{@name}'s hand is:"
    @hand.each do |card|
      card.show_card
    end
    puts "for a value of: " + self.best_value.to_s
    puts
  end

  def play_hand(deck)
    continue = true

    while continue
      self.show_hand
      if  self.best_value > 21 
        puts "I'm sorry, you busted - you lose this hand."
        @game_value = 0
        break
      elsif self.best_value == 21 && @hand.size == 2
        "#{@name} got a Blackjack! You win!"
        @game_value = 22
        break        
      end

      puts "Would you like to (h)it or (s)tay?"
      hit_or_stay = gets.chomp
      if hit_or_stay == 's'
        puts "OK, you are staying with a hand value of #{self.best_value}"
        @game_value = self.best_value
        continue = false
      else
        puts "Hit!"
        self.take_card(deck.deal)
      end
    end
  end
end 

class Dealer < Player
  def show_hand
    puts "The Dealer's hand is:"
    @hand.each do |card|
      card.show_card
    end
    puts "for a value of: " + self.best_value.to_s
    puts
  end

  def play_hand(deck)
    hit_or_stay = true

    while hit_or_stay
      self.show_hand
      if  self.best_value > 21
        puts "Dealer busted!"
        @game_value = 0
        break
      elsif self.best_value < 17
        puts "Dealer hits"
        self.take_card(deck.deal)
      else
        puts "Dealer stays"
        @game_value = self.best_value
        hit_or_stay = false
      end
    end
  end
end 


class Card
  #Card is never updated once created, and suit is only relevant when showing the whole card.
  attr_reader :face 

  def initialize(face, suit)
    @face = face
    @suit = suit
  end

  def show_card
    puts @face.to_s + ' of ' + @suit.to_s
  end
end

class Game
  def initialize(gamblers, deck)
    @gamblers = gamblers
    @deck = deck
    @dealer = Dealer.new
  end

  def play_single_game
    puts "OK, let's play a new game!"

    @deck.shuffle

    2.times do 
      @gamblers.each do |gambler|
        gambler.take_card(@deck.deal)
      end
      @dealer.take_card(@deck.deal)
    end

    if @dealer.best_value == 21
      puts "Dealer Blackjack! Dealer takes all."
      return # Game is finished if Dealer has Blackjack
    end

    @gamblers.each do |gambler|
      gambler.play_hand(@deck)
    end

    @dealer.play_hand(@deck)

    @gamblers.each do |gambler|
      if gambler.game_value == 22 
        puts "#{gambler.name} had a Blackjack - Congratulations!"
      elsif gambler.game_value == 0
        puts "#{gambler.name} busted. Please try again!"
      elsif gambler.game_value > @dealer.game_value
        puts "#{gambler.name} wins!"
      elsif gambler.game_value == @dealer.game_value
        puts "#{gambler.name} and the Dealer ties - push."
      else
        puts "Dealer has beaten #{gambler.name}.  Please try again!"
      end
    end
  end


end


puts "Hello, what's your name?"
name = gets.chomp

player = Gambler.new(name)
deck = Deck.new
game = Game.new([player], deck)

game.play_single_game


# puts "Hello #{name}, let's play some Blackjack.  How many decks would you like to use?"
# deck_count = gets.chomp.to_i

# deck = []
# deck_count.times {add_deck(deck)}

# puts "OK, we are using #{deck_count.to_s} decks. Would you like to shuffle the deck(s) each game? (y/n)"
# shuffle_each_game = gets.chomp

# puts "Alright! Let's play."

# keep_playing = 'y'
# game_deck = deck.shuffle

# while keep_playing == 'y'
#   if shuffle_each_game.downcase == 'y'
#     game_deck = deck.shuffle #start with complete fresh deck
#   end


#   puts "Would you like to play another game? (y/n)"
#   keep_playing = gets.chomp.downcase
# end

