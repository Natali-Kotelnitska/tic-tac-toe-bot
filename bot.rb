require 'dotenv/load'
require 'telegram/bot'
require_relative 'game'

class TelegramBot
  def initialize
    @game = nil
    @play_with_computer = false
  end

  def run
    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
      bot.listen { |message| handle_message(bot, message) }
    end
  end

  private

  def handle_message(bot, message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      handle_callback(bot, message)
    when Telegram::Bot::Types::Message
      handle_text_message(bot, message)
    end
  end

  def handle_callback(bot, message)
    if @game
      x, y = message.data.split(',').map(&:to_i)
      @game.make_move(x, y)
      if @play_with_computer && @game.instance_variable_get(:@current_player) == @game.instance_variable_get(:@player)
        x, y = @game.computer_move
        @game.make_move(x, y)
      end
      handle_game_over(bot, message) if @game.game_over?
    end
  end

  def handle_text_message(bot, message)
    case message.text
    when '/start'
      send_initial_message(bot, message)
    when 'With player'
      @play_with_computer = false
      start_new_game(bot, message)
    when 'With computer'
      @play_with_computer = true
      start_new_game(bot, message)
    when '/stop'
      @game = nil
      bot.api.send_message(chat_id: message.chat.id, text: "Game stopped.")
    end
  end

  # Methods for handling different message cases

  def send_initial_message(bot, message)
    user_full_name = "#{message.from.first_name} #{message.from.last_name}"
    bot.api.send_message(chat_id: message.from.id, text: "Hello #{user_full_name} 👋")
    bot.api.send_message(chat_id: message.chat.id, text: "I'm your Tic Tac Toe bot. You can play a game of Tic Tac Toe with a friend or with the computer. To start a new game, please choose 'With player' or 'With computer'.")
    question = 'How do you want to play?'
    answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'With player' }, { text: 'With computer' }],
      ],
      one_time_keyboard: true
    )
    bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
  end

  def handle_game_over(bot, message)
    winner = @game.instance_variable_get(:@current_player) == @game.instance_variable_get(:@player) ? @game.instance_variable_get(:@opponent) : @game.instance_variable_get(:@player)
    bot.api.send_message(chat_id: message.message.chat.id, text: "Game over. The winner is #{winner}.")
    @game = nil
  end

  def start_new_game(bot, message)
    @game = Game.new(bot, message)
    @game.play
  end
end
