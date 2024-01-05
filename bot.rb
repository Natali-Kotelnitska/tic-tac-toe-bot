# frozen_string_literal: true

require_relative 'board'
require_relative 'keyboard_creator'

# Class representing a TelegramBot.
class TelegramBot
  include KeyboardCreator

  def initialize
    @board = Board.new
    @game = nil
    @play_with_computer = false
    @difficulty_level = 0
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
    case message.data
    when 'new_game'
      start_new_game(bot, message.message)
    else
      handle_game_move(bot, message)
    end
  end

  def handle_game_move(bot, message)
    return unless @game

    x, y = message.data.split(',').map(&:to_i)
    @game.make_move(x, y)
    game_status = @game.game_over?

    if game_status
      handle_game_over(bot, message, game_status)
    elsif @play_with_computer && !game_status
      handle_computer_move(bot, message)
    end
  end

  def handle_computer_move(bot, message)
    x, y = @game.computer_move(@difficulty_level)
    @game.make_move(x, y)
    game_status = @game.game_over?

    handle_game_over(bot, message, game_status) if game_status
  end

  MESSAGE_ACTIONS = {
    '/start' => :send_initial_message,
    'With player' => :handle_with_player_message,
    'With computer' => :send_difficulty_level_message,
    'Easy' => :handle_difficulty_level1,
    'Medium' => :handle_difficulty_level4,
    'Hard' => :handle_difficulty_level6,
    '/stop' => :handle_stop_message
  }.freeze

  def handle_text_message(bot, message)
    action = MESSAGE_ACTIONS[message.text]
    send(action, bot, message) if action
  end

  [1, 4, 6].each do |level|
    define_method("handle_difficulty_level#{level}") do |bot, message|
      handle_difficulty_level(level, bot, message)
    end
  end

  def handle_with_player_message(bot, message)
    @play_with_computer = false
    start_new_game(bot, message)
  end

  def send_difficulty_level_message(bot, message)
    question = 'Choose the difficulty level:'
    answers = create_difficulty_level_keyboard
    bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
  end

  def handle_stop_message(bot, message)
    @game = nil
    bot.api.send_message(chat_id: message.chat.id, text: 'Game stopped.')
    bot.api.send_message(chat_id: message.chat.id, text: "Thank you for playing! Bye, #{message.from.first_name}")
  end

  def handle_difficulty_level(difficulty_level, bot, message)
    @difficulty_level = difficulty_level
    @play_with_computer = true
    start_new_game(bot, message)
  end

  def send_initial_message(bot, message)
    bot.api.send_message(chat_id: message.from.id, text: "Hello, #{message.from.first_name} 👋")
    bot.api.send_message(chat_id: message.chat.id, text: "I'm your Tic Tac Toe bot.")
    question = 'How do you want to play?'
    answers = create_keyboard
    bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
  end

  def handle_game_over(bot, message, game_status)
    if game_status == :draw
      bot.api.send_message(chat_id: message.message.chat.id, text: "Game over. It's a draw.")
    else
      winner = @game.determine_winner
      bot.api.send_message(chat_id: message.message.chat.id, text: "Game over. The winner is #{winner}.")
    end
    send_new_game_button(bot, message)
    @game = nil
  end

  def start_new_game(bot, message)
    @game = Game.new(bot, message)
    @game.play
  end
end
