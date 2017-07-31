# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Blob.delete_all
10.times do |company_n|
  company = (10000+company_n).to_s
  10_000.times do |blob_n|
    Blob.create(company: company, blob: {
      name: "Blob #{blob_n}",
      number: Random::rand(100),
    })
  end
end
