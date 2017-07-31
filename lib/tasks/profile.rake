desc 'Profile the performance of multiple database requests'
task profile: [:environment] do

  puts 'running benchmarks...'

  # LEARNINGS
  # 1. We have confirmed we are really running threads concurrently.
  # 2. Real time is what matters; the others may just be CPU time
  # 3. Sleeping (at least) threads do not take up a processor; other threads can be substituted in
  # 4. With pg_sleep() we confirmed that Ruby/Rails can execute multiple long-running SQL queries concurrently, limited by the connection pool
  # 5. Retrieving and summing an integer from a JSONB column, we confirmed that Ruby/Rails can execute multiple long-running SQL queries doing real database work concurrently.

  concurrent = ->(company_ids) {
    threads = company_ids.map do |company_id|
      Thread.new do
        # ActiveRecord::Base.connection.execute('select pg_sleep(1)')
        query = "SELECT SUM((blob->>'number')::int) FROM blobs WHERE company = '#{company_id}'"
        ActiveRecord::Base.connection.execute(query)
        # Blob.where(company: company_id).to_a.count
        # sleep(1)
        0
      end
    end

    total = 0
    threads.each do |thread|
      total += thread.value
    end
  }

  sequential = ->(company_ids) {
    total = company_ids.reduce(0) do |total, company_id|
      # ActiveRecord::Base.connection.execute('select pg_sleep(1)')
      query = "SELECT SUM((blob->>'number')::int) FROM blobs WHERE company = '#{company_id}'"
      ActiveRecord::Base.connection.execute(query)

      # total += Blob.where(company: company_id).to_a.count
      # sleep(1)
      0
    end
  }

  Benchmark.bm do |x|
    # company_ids = Blob.distinct.pluck(:company)
    company_ids = ["10000", "10003", "10008", "10004", "10002", "10006", "10009", "10001", "10007", "10005"]

    # query = "SELECT SUM((blob->>'number')::int) FROM blobs"

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
