# use only for development purposes
# tinker it to your needs since this will create a very big data around 500k sleep_records
# and 1000 users with 20-50 followers each
# Run this with `rails db:seed` or `rails db:reset` to clear existing data and reseed
# This will take a while to run, so be patient!
# This file is being used to run benchmark for performance testing

# Load Faker for random data generation


require 'faker'

# Clear existing data to avoid duplication
SleepRecord.destroy_all
User.destroy_all
Follow.destroy_all

puts "Starting gigantic data seeding..."

# Create 1,000 users with Faker data
1000.times do |i|
  user = User.create!(name: Faker::Name.name)
  puts "Created user #{i+1}: #{user.name}"

  # Create between 20 to 50 followers for each user
  rand(20..50).times do
    follower = User.create!(name: Faker::Name.name)
    Follow.create!(follower_id: follower.id, followed_id: user.id)
    # Comment out the next line if too verbose:
    puts "Created follow relationship: Follower #{follower.name} -> Followed #{user.name}"
  end

  # Create between 200 to 500 sleep records for each user
  rand(200..500).times do
    # clock_in between 5 years ago and now
    clock_in = Faker::Time.between(from: 5.years.ago, to: Time.now)
    clock_out = clock_in + Faker::Number.between(from: 5, to: 10).hours

    # Random sleep durations (these values can be independent of the actual duration)
    sleep_days    = Faker::Number.between(from: 0, to: 7)
    sleep_hours   = Faker::Number.between(from: 3, to: 9)
    sleep_minutes = Faker::Number.between(from: 0, to: 59)
    # Calculate total minutes and then total_time in seconds
    total_minutes = ((clock_out - clock_in) / 60).to_i
    total_time    = total_minutes * 60

    # Randomly assign updated_at from various timeframes, including very old dates.
    updated_at = case Faker::Number.between(from: 1, to: 6)
    when 1 then 3.months.ago + Faker::Number.between(from: 0, to: 30).days
    when 2 then 1.month.ago + Faker::Number.between(from: 0, to: 30).days
    when 3 then 1.week.ago + Faker::Number.between(from: 0, to: 7).days
    when 4 then Time.now + Faker::Number.between(from: -30, to: 0).days
    when 5 then Faker::Time.between(from: 3.years.ago, to: 5.years.ago)
    when 6 then Faker::Time.between(from: 5.years.ago, to: 7.years.ago)
    end

    SleepRecord.create!(
      user_id: user.id,
      clock_in: clock_in,
      clock_out: clock_out,
      sleep_days: sleep_days,
      sleep_hours: sleep_hours,
      sleep_minutes: sleep_minutes,
      total_time: total_time,
      updated_at: updated_at
    )
    # Comment out the next line if output is too verbose:
    puts "Created sleep record for user #{user.name}: #{clock_in} - #{clock_out} (Updated at: #{updated_at})"
  end
end

puts "Data seeding complete!"
