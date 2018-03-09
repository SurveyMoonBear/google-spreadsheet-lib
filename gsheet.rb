require 'google/apis/sheets_v4'

module GsheetLib
  # Operations about Google spreadsheet
  class Spreadsheet
    def initialize(sheet_service, drive_service)
      @sheet_service = sheet_service
      @drive_service = drive_service
    end

    # def get_sheet(spreadsheet_id)
    #   @sheet_service.get_spreadsheet(spreadsheet_id)
    # end

    def create
      request_body = Google::Apis::SheetsV4::Spreadsheet.new
      @sheet_service.create_spreadsheet(request_body)
    end

    def copy_to(spreadsheet_id_from, spreadsheet_id_to)
      request_body = Google::Apis::SheetsV4::CopySheetToAnotherSpreadsheetRequest.new
      request_body.destination_spreadsheet_id = spreadsheet_id_to
      @sheet_service.copy_spreadsheet(spreadsheet_id_from, 0, request_body)
    end

    def sheets(spreadsheet_id)
      response = @sheet_service.get_spreadsheet(spreadsheet_id)
      puts response.sheets.to_json
    end

    def read(spreadsheet_id, range)
      response = @sheet_service.get_spreadsheet_values(spreadsheet_id, range)
      puts 'No data found.' if response.values.empty?
      puts response.values.to_json
    end

    def list
      files = @drive_service.fetch_all(items: :files) do |page_token|
        @drive_service.list_files(q: "mimeType='application/vnd.google-apps.spreadsheet'",
                                 spaces: 'drive',
                                 fields: 'nextPageToken, files(id, name)',
                                 page_token: page_token)
      end
      files.each do |file|
        # Process change
        puts "Found file: #{file.name} #{file.id}"
      end
    end

    def delete_sheet(spreadsheet_id)
      @drive_service.delete_file(spreadsheet_id)
    end

    def add_member(spreadsheet_id, user_email)
      callback = lambda do |res, err|
        if err
          # Handle error...
          puts err.body
        else
          puts "Permission ID: #{res.id}"
        end
      end

      @drive_service.batch do |service|
        user_permission = {
            type: 'user',
            role: 'writer',
            email_address: user_email
        }
        service.create_permission(spreadsheet_id,
                                  user_permission,
                                  fields: 'id',
                                  &callback)
      end
    end
  end
end
