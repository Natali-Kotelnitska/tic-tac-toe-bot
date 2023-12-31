# frozen_string_literal: true

# Class representing a Tic Tac Toe game.
class Game
  def initialize(bot, message)
    @board = Array.new(3) { Array.new(3, '-') }
    @message = message
    @bot = bot
    @player = '🎅' # Санта Клаус
    @opponent = '🧛' # Вампір
    @current_player = @player
  end

  def play
    print_board
  end

  def make_move(x, y)
    @board[x][y] = @current_player
    switch_player
    print_board
  end

  def computer_move
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        if cell == '-'
          return [i, j]
        end
      end
    end
  end

  def game_over?
    # Перевірка рядків
    @board.each do |row|
      return true if row.uniq.length == 1 && row[0] != '-'
    end

    # Перевірка стовпців
    @board.transpose.each do |col|
      return true if col.uniq.length == 1 && col[0] != '-'
    end

    # Перевірка діагоналей
    return true if [@board[0][0], @board[1][1], @board[2][2]].uniq.length == 1 && @board[0][0] != '-'
    return true if [@board[0][2], @board[1][1], @board[2][0]].uniq.length == 1 && @board[0][2] != '-'

    # Перевірка, чи всі клітинки заповнені
    return :draw unless @board.flatten.include?('-')

    false
  end

  private

  def print_board
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: @board.map.with_index do |row, i|
      row.map.with_index do |cell, j|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: cell, callback_data: "#{i},#{j}")
      end
    end)
    @bot.api.send_message(chat_id: @message.chat.id, text: "Player's #{@current_player} turn", reply_markup: markup)
  end

  def switch_player
    @current_player = @current_player == @player ? @opponent : @player
  end
end
