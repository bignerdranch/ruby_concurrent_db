desc 'Profile the performance of multiple database requests'
task profile: [:environment] do
  puts "user system sum"

  companies = Blob.distinct.pluck(:company)

  Benchmark.bm do |x|
    x.report("sequential") do
      companies.each do |company|
        Blob.where(company: company).to_a
      end
    end
  end
end
