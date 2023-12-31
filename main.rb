require 'dotenv/load'
require 'telegram/bot'

require_relative 'game'
require_relative 'bot'

TelegramBot.new.run
