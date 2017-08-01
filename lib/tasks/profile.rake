desc 'Profile the performance of multiple database requests'
task profile: [:environment] do

  puts 'running benchmarks...'

  work = ->(company_id) {
    query = "SELECT pg_sleep(1)"
    # query = "SELECT SUM((blob->>'number')::int) FROM blobs WHERE company = '#{company_id}'"
    ActiveRecord::Base.connection.execute(query)
  }

  concurrent = ->(company_ids) {
    threads = company_ids.map do |company_id|
      Thread.new do
        work.call(company_id)
      end
    end
    threads.each(&:join)
  }

  sequential = ->(company_ids) {
    company_ids.each do |company_id|
      work.call(company_id)
    end
  }

  Benchmark.bm do |x|
    # company_ids = Blob.distinct.pluck(:company)
    company_ids = ["10000", "10003", "10008", "10004", "10002", "10006", "10009", "10001", "10007", "10005"]

    sequential.call(company_ids)
    concurrent.call(company_ids)

    x.report("sequential") do
      sequential.call(company_ids)
    end

    x.report("concurrent") do
      concurrent.call(company_ids)
    end
  end
end
