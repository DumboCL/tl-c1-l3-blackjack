require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_AMOUNT = 17
CARDS_SUIT = ['♠︎','♥︎','♣︎','♦︎']
CARDS_RANK = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']


helpers do
  def calculate_total(cards)
    result = 0
    ace_count = 0

    cards.each do |card|
      if card[:rank].to_i == 0
        if card[:rank] == 'A'
          ace_count = ace_count + 1
        else
          result += 10
        end
      else
        result += card[:rank].to_i
      end
    end

    if ace_count > 0
      begin
        case 
        when result <= 10
          result += 11
        when result >10
          result += 1  
        end
        ace_count -= 1
      end while ace_count > 0
    end
    result
  end
  
  def card_image(card)
    if card.is_a?(String)
      "<img src='/images/cards/cover.jpg' class='card_image'>"
    else
      suit = case card[:suit]
        when '♠︎' then 'spades'
        when '♥︎' then 'hearts'
        when '♣︎' then 'clubs'
        when '♦︎' then 'diamonds'     
      end      
      value = card[:rank]
      if ['J', 'Q', 'K', 'A'].include?(value)
        value = case card[:rank]
          when 'J' then 'jack'
          when 'Q' then 'queen'
          when 'K' then 'king'
          when 'A' then 'ace'
        end
      end
      "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"      
    end
  end
end

before do
  @show_hit_or_stay_buttons = true
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "The name can't be empty"
    halt erb(:set_name)
  end 
  session[:player_name] = params[:player_name]
  erb :set_name
end

post '/stay' do
  @show_hit_or_stay_buttons = false
  @show_dealer_cards = true
  @error = "You choose 'Stay', now it's dealer's turn."
  redirect '/dealer'
end

post '/hit' do
  session[:player_cards] << session[:cards].sample
  @show_dealer_cards = false
  if calculate_total(session[:player_cards]) > BLACKJACK_AMOUNT
    @error = "You busted!"
    @show_hit_or_stay_buttons = false
    @show_dealer_cards = true
  elsif calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    @error = "Aha, blackjack, you win!!"
    @show_hit_or_stay_buttons = false
    @show_dealer_cards = true
  end    
  erb :game
end

get '/dealer' do
  @show_hit_or_stay_buttons = false
  @show_dealer_cards = true
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK_AMOUNT
    @error = "Sorry, dealer hit blackjack."
  elsif dealer_total > BLACKJACK_AMOUNT
    @success = "Congratulations, dealer busted. You win."
  elsif dealer_total >= DEALER_MIN_AMOUNT
    #dealer stay
    redirect '/compare'
  else
    #dealer hits
    @show_dealer_hit_button = true
  end
  erb :game     
end

post '/dealer/hit' do
  session[:dealer_cards] << session[:cards].sample
  redirect 'dealer'
end

get '/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  if player_total < dealer_total
    @error = 'Sorry, you lost.'
  elsif player_total > dealer_total
    @success = 'Congrats, you won!'
  else
    @success = "It's a tie!"
  end
  @show_dealer_cards = true
  @show_hit_or_stay_buttons = false
  erb :game
end

get '/' do
  erb :set_name
end

get '/player_profile'  do
  erb :"/profile/player"
end

get '/game' do
  cards = []
    CARDS_SUIT.each do |suit_value|
      CARDS_RANK.each do |rank_value|
        cards << {suit: suit_value, rank: rank_value}
      end
    end
  session[:cards] = cards
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:cards].sample
  session[:player_cards] << session[:cards].sample
  session[:dealer_cards] << session[:cards].sample
  session[:dealer_cards] << session[:cards].sample
  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    @error = "Aha, blackjack, you win!!"
    @show_hit_or_stay_buttons = false
    @show_dealer_cards = true
    @show_dealer_hit_button = false
  end
  erb :game
end
