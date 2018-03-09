require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative 'sheet_opt.rb'

describe 'Test Gsheet Library' do
  APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'.freeze
  CLIENT_SECRETS_PATH = 'client_secret.json'.freeze
  SCOPE = ['https://www.googleapis.com/auth/spreadsheets',
           'https://www.googleapis.com/auth/drive.file'].freeze
  describe 'Get Google Authorization' do
    spreadsheet = GsheetLib::GoogleAPI.new(APPLICATION_NAME, CLIENT_SECRETS_PATH, SCOPE).spreadsheet
  end
end
