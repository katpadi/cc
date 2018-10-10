module Cc
  class Analyzer

    attr_reader :input_file, :json_file
    def initialize(input_file, output_dir: nil)
      @input_file = input_file
      @json_file = output_dir.nil? ? "#{Cc::results_dir}/cc.json"  : "#{output_dir}/cc.json"
    end

    def execute
      h = {}
      customer_name = nil
      SmarterCSV.process(input_file, chunk_size: 500) do |chunks|
        chunks.each do |row|
          aggregated_info = Cc::AggregatedInfo.new(row[:info])
          key = aggregated_info.key

          if h[key] == nil
            count = 1
          else
            count = h[key][:count] + 1 rescue 1
          end

          if h[key] == nil
            amount = row[:amount]
          else
            amount = h[key][:amount] + row[:amount]
          end

          customer_name = row[:customer_name] if customer_name.nil?

          # customer_name,file,statement_date,page,transaction_date,post_date,aggregated_info,currency,amount
          f_amount = "%05.2f" % amount
          f_amount = f_amount.reverse.gsub(/(\d{3})(?=\d)/,'\\1,').reverse
          h.merge!({
            key => {
              label: aggregated_info.chars,
              amount: amount.round(2),
              formatted_amount: f_amount,
              count: count,
              percentage: 0,
              statement_date: row[:statement_date],
              page: row[:page]
            }
          })
        end
      end

      arr = h.values
      returned_transactions = arr.select{|x| x[:amount] < 0  }
      sum_of_non_negative = arr.inject(0) { |sum, has| (has[:amount] > 0 ) ? sum + has[:amount] : sum }

      # Compute percentage out of TOTAL statements
      # TODO: Per month?
      h.each_with_object({}) do |(k, v), storage|
        next if h[k][:amount] < 0
        h[k][:percentage] = (h[k][:amount] * 100.0 / sum_of_non_negative).round(2)
      end

      sorted_by_highest = h.sort {|(k1,v1), (k2,v2)| v2[:amount] <=> v1[:amount]  }

      json_formatted = { customer_name: customer_name, mydata: h.values }
      File.open(json_file, "w") do |f|
        f.write(json_formatted.to_json)
      end
    end
  end
end
