def profile(&work)
  company_ids = ["10000", "10003", "10008", "10004", "10002", "10006", "10009", "10001", "10007", "10005"]

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
    # pre-run each sequence in case it
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

namespace :profile do
  desc 'Profile the performance of threads running the Ruby sleep command'
  task :rubysleep do
    profile { sleep(1) }
  end

  desc 'Profile the performance of threads running a PG query with the pg_sleep command'
  task pgsleep: [:environment] do
    profile do |company_id|
      query = 'SELECT pg_sleep(1)'
      ActiveRecord::Base.connection.execute(query)
    end
  end

  desc 'Profile the performance of multiple long-running database requests'
  task pgquery: [:environment] do

    profile do |company_id|
      query = "SELECT SUM((blob->>'number')::int) FROM blobs WHERE company = '#{company_id}'"
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
