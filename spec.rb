require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative 'sheet_opt.rb'

describe 'Test Gsheet Library' do
  APPLICATION_NAME = 'GSpreadsheet Library'.freeze
  CLIENT_SECRETS_PATH = 'client_secret.json'.freeze
  SCOPE = ['https://www.googleapis.com/auth/spreadsheets',
           'https://www.googleapis.com/auth/drive.file'].freeze
  SPREADSHEET_EXIST = '1ItCeIVWgVRanDJ3vaZ7gd7ByuKC69Y5U8WLI-VP0sSA'.freeze
  SHEET_ID = 0
  RANGE = 'sheet1'.freeze
  USER_EMAIL = 'wehuin1215@gmail.com'

  describe 'Oprations on Google Spreadsheet' do
    before do
      @spreadsheet = GsheetLib::GoogleAPI.new(APPLICATION_NAME, CLIENT_SECRETS_PATH, SCOPE).spreadsheet
    end

    it 'Copy a exist sheet of one spreadsheet to another' do
      new_spreadsheet = @spreadsheet.create
      copy_sheet = @spreadsheet.copy_to(SPREADSHEET_EXIST, SHEET_ID, new_spreadsheet.spreadsheet_id)

      _(copy_sheet.index).must_equal 1
    end

    it 'Read all the sheets documents from one exist spreadsheet' do
      sheets = @spreadsheet.sheets(SPREADSHEET_EXIST)

      _(sheets.length).must_equal 5
    end

    it 'Read the content of an exist sheet' do
      read_sheet = @spreadsheet.read(SPREADSHEET_EXIST, RANGE)

      _(read_sheet.length).must_equal 11
    end

    it 'List all the spreadsheet we have' do
      new_spreadsheet = @spreadsheet.create
      list = @spreadsheet.list_all_spreadsheet
      files_id = list.map(&:id)

      _(files_id).must_include new_spreadsheet.spreadsheet_id
    end

    it 'Add a co-author to an exist spreadsheet' do
      new_spreadsheet = @spreadsheet.create
      permission = @spreadsheet.add_member(new_spreadsheet.spreadsheet_id, USER_EMAIL)

      _(permission).must_be_instance_of Google::Apis::DriveV3::Permission
    end

    it 'Delete an exist spreadsheet' do
      new_spreadsheet = @spreadsheet.create
      response = @spreadsheet.delete_spreadsheet(new_spreadsheet.spreadsheet_id)

      _(response).must_be_empty
    end
  end
end
