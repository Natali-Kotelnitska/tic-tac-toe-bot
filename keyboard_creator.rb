module KeyboardCreator
  def create_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'With player' }, { text: 'With computer' }]
      ],
      one_time_keyboard: true
    )
  end

  def create_difficulty_level_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Easy' }, { text: 'Medium' }, { text: 'Hard' }]
      ],
      one_time_keyboard: true
    )
  end

  def send_new_game_button(bot, message)
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Start New Game', callback_data: 'new_game')]
      ]
    )
    bot.api.send_message(chat_id: message.message.chat.id, text: 'Click the button below to start a new game, or type /start to start over.', reply_markup: markup)
  end
end
