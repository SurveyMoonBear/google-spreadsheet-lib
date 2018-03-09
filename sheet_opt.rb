require 'google/apis/sheets_v4'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'
require_relative 'gsheet.rb'

module GsheetLib
  # get access go Google API
  class GoogleAPI
    def initialize(application_name, client_secret_path, scope)
      @application_name = application_name
      @client_secret_path = client_secret_path
      @scope = scope
    end

    def spreadsheet
      sheet_service = Google::Apis::SheetsV4::SheetsService.new
      sheet_service.client_options.application_name = @application_name
      sheet_service.authorization = authorize

      drive_service = Google::Apis::DriveV3::DriveService.new
      drive_service.client_options.application_name = @application_name
      drive_service.authorization = authorize
      Spreadsheet.new(sheet_service, drive_service)
    end

    private

    def authorize
      oob_uri = 'urn:ietf:wg:oauth:2.0:oob'
      credentials_path = File.join(Dir.home, '.credentials',
                                  'sheets.googleapis.com-ruby-quickstart.yaml')

      FileUtils.mkdir_p(File.dirname(credentials_path))

      client_id = Google::Auth::ClientId.from_file(@client_secret_path)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: credentials_path)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, @scope, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: oob_uri)
        puts 'Open the following URL in the browser and enter the' +
             'resulting code after authorization'
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
                        user_id: user_id, code: code, base_url: oob_uri)
      end
      credentials
    end
  end
end
