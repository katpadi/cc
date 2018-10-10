module Cc
  class Parser
    PATTERN = /\d{6}-\d-\d{2}-\d{7}\s+-/
    PATTERN2 = 'Installment Amortization:'.freeze
    FIRST_PAGE_PATTERN = 'S T A T E M E N T D A T E'.freeze
    START_PAGE = 3

    attr_reader :statements, :output_file

    def initialize(input_path, output_dir: nil)
      @statements = Dir["#{input_path}/*.pdf"].sort_by(&:downcase)
      @output_file = output_dir.nil? ? "#{Cc::results_dir}/result.csv" : "#{output_dir}/result.csv"
    end

    def execute
      puts "YEAH!"
      puts output_file
      CSV.open(output_file, "w+") do |csv|
        csv << %w(customer_name file statement_date page transaction_date post_date info currency amount)
        statements.each do |statement|
          puts "STATEMENT NAME: #{statement} "
          reader   = PDF::Reader.new(statement)
          statement_name = statement.split("/").last.split(".").first

          first_page = reader.page(1)

          fpt = first_page.text.partition(FIRST_PAGE_PATTERN)
          st_info = fpt.last.split("\n")

          # IMPROVE: Kludge
          statement_date = st_info[0].squeeze(" ")

          st_date = statement_date.to_st_date

          customer_name = st_info[1].squeeze(" ")
          # statement_date[0] = ''
          customer_name[0] = ''

          page_count = reader.page_count
          first_page_of_statement_found = false
          p = START_PAGE
          while p <= page_count
            page = reader.page(p)

            # If pattern is found and first page has not been marked...
            if PATTERN.match(page.text) && !first_page_of_statement_found

              data = page.text.partition(PATTERN2).last

              first_page_of_statement_found = true
            else
              if !first_page_of_statement_found
                p = p + 1
                next
              end
              data = page.text
            end

            rows =  data.split("\n")
            merge_rows = []
            merge_info_text = ''
            rows.each do |col|
              next if col == ''
              col_data = col.strip.split(/(?:[[:space:]][[:space:]][[:space:]][[:space:]][[:space:]]+)/)

              # Last column value is always the amount
              amount = col_data.pop
              txn_date = col_data[0]
              post_date = col_data[1]
              l = col_data.length
              col_info_index = 2
              info_text = ''
              while col_info_index <= l
                info_text << " #{col_data[col_info_index]} " if !col_data[col_info_index].nil?
                col_info_index = col_info_index + 1
              end
              currency = nil
              amount.gsub!(" ", "").gsub!(",", "")

              # If amount is not numeric, it is a non-PH transaction and
              # the details are a bit messed up:
              # It has 2 rows so we combine these 2 rows.
              if !amount.numeric?
                currency = amount
                amount = nil
              end

              # If amount is nil, it's the 1st row of a non-PH transaction
              if amount.nil?
                merge_info_text = info_text
                merge_rows = [statement_name,p,txn_date,post_date,nil,currency,nil]
                next
              end

              # if there's no info_text, it's the 2nd row of a non-PH transaction.
              # We merge the other details into 1 row.
              if info_text == ''
                merge_info_text << " [#{txn_date} - #{post_date}]"
                merge_rows[4] = merge_info_text
                merge_rows[6] = amount

                # Re-init
                merge_rows = []
                merge_info_text = ''
                next
              end

              csv << [customer_name,statement_name,st_date,p,txn_date,post_date,info_text,currency,amount]
            end

            p = p + 1
          end
        end
      end
    end
  end
end

