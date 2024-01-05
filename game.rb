# frozen_string_literal: true

require_relative 'board'
require_relative 'players'
# Class representing a Tic Tac Toe game.
class Game
  include Players

  def initialize(bot, message)
    @board_instance = Board.new
    @board = @board_instance.board
    @message = message
    @bot = bot
    @player = PLAYER
    @opponent = OPPONENT
    @current_player = @player
  end

  def play
    @board_instance.print_board(@current_player, @bot, @message)
  end

  def make_move(x, y)
    @board[x][y] = @current_player
    switch_player
    play
  end

  def minimax(board, depth, is_maximizing, level)
    winner = check_winner(board)

    return 10 - depth if winner == :opponent
    return -10 + depth if winner == :player
    return 0 if winner == :draw
    return 0 if depth == level

    best_score = is_maximizing ? -Float::INFINITY : Float::INFINITY
    current_player = is_maximizing ? @opponent : @player
    next_maximizing = !is_maximizing

    evaluate_board(board, current_player, depth, next_maximizing, best_score, level)
  end

  def evaluate_board(board, current_player, depth, next_maximizing, best_score, level)
    board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        next unless cell == '-'

        board[i][j] = current_player
        score = minimax(board, depth + 1, next_maximizing, level)
        board[i][j] = '-'

        best_score = next_maximizing ? [score, best_score].min : [score, best_score].max
      end
    end
    best_score
  end

  def computer_move(level)
    best_score = -Float::INFINITY
    move = nil

    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        if cell == '-'
          @board[i][j] = @opponent
          score = minimax(@board, 0, false, level)
          @board[i][j] = '-'
          if score > best_score
            best_score = score
            move = [i, j]
          end
        end
      end
    end

    move
  end

  def check_winner(board)
    # Перевірка рядків
    board.each do |row|
      return :opponent if row.all? { |cell| cell == @opponent }
      return :player if row.all? { |cell| cell == @player }
    end

    # Перевірка стовпців
    board.transpose.each do |col|
      return :opponent if col.all? { |cell| cell == @opponent }
      return :player if col.all? { |cell| cell == @player }
    end

    # Перевірка діагоналей
    return :opponent if [board[0][0], board[1][1], board[2][2]].all? { |cell| cell == @opponent }
    return :player if [board[0][0], board[1][1], board[2][2]].all? { |cell| cell == @player }
    return :opponent if [board[0][2], board[1][1], board[2][0]].all? { |cell| cell == @opponent }
    return :player if [board[0][2], board[1][1], board[2][0]].all? { |cell| cell == @player }

    # Перевірка, чи всі клітинки заповнені
    return :draw unless board.flatten.include?('-')

    # Якщо гра ще не закінчилася, повертаємо nil
    nil
  end

  def determine_winner
    @current_player == @player ? @opponent : @player
  end

  def game_over?
    winner = check_winner(@board)
    return true if [:player, :opponent].include?(winner)
    return :draw if winner == :draw

    false
  end

  private

  def switch_player
    @current_player = @current_player == @player ? @opponent : @player
  end
end
