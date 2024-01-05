# frozen_string_literal: true

# Class representing a Board of Tic Tac Toe game.
class Board
  attr_accessor :board

  def initialize
    @board = Array.new(3) { Array.new(3, '-') }
  end

  def print_board(current_player, bot, message)
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: @board.map.with_index do |row, i|
      row.map.with_index do |cell, j|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: cell, callback_data: "#{i},#{j}")
      end
    end)
    bot.api.send_message(chat_id: message.chat.id, text: "Player's #{current_player} turn", reply_markup: markup)
  end
end
