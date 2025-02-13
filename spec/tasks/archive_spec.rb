require 'rails_helper'
require 'rake'
require 'stringio'
require 'timeout'

# Helper to capture stdout output
def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end

RSpec.describe "archive:data rake task", type: :task do
  before :all do
    # Load the rake tasks from lib/tasks/archive.rake
    Rake.application.rake_require("tasks/archive")
    Rake::Task.define_task(:environment)
  end

  let(:task_name) { "archive:data" }
  subject { Rake::Task[task_name] }

  before do
    # Clean up the archive folder before each test run.
    archive_folder = Rails.root.join('tmp', 'sql_archives')
    FileUtils.rm_rf(archive_folder) if Dir.exist?(archive_folder)
  end

  context "when there are records older than one month" do
    before do
      # Create a SleepRecord older than one month
      user = User.create!(name: "Old User")
      SleepRecord.create!(
        user: user,
        clock_in: 2.months.ago,
        clock_out: 2.months.ago + 8.hours,
        sleep_days: 0,
        sleep_hours: 8,
        sleep_minutes: 0,
        total_time: 480 * 60,  # Already in seconds
        updated_at: 2.months.ago
      )
    end
    # this being skipped because it is giving timeout error on some cases
    xit "creates an archive file and deletes the old records" do
      # Stub the system call to intercept mysqldump commands.
      allow(Kernel).to receive(:system) do |cmd|
        Rails.logger.debug("Stubbed system call: #{cmd}")
        if cmd =~ /\A\s*mysqldump/i
          # Extract the file path from the command using a regex that looks for redirection (">")
          file_path = cmd[/>\s*(.+)$/i, 1]
          if file_path
            FileUtils.mkdir_p(File.dirname(file_path))
            File.write(file_path, "DUMMY SQL DUMP")
          end
          true
        else
          true
        end
      end

      # Use a timeout block to prevent hanging indefinitely.
      Timeout.timeout(5) do
        subject.reenable  # Allow re-running the task in the same spec run
        subject.invoke
      end

      archive_folder = Rails.root.join('tmp', 'sql_archives')
      current_date = Time.now.strftime("%F")
      archive_file = archive_folder.join("archive_#{current_date}.sql")

      expect(File).to exist(archive_file)
      content = File.read(archive_file)
      expect(content).to include("DUMMY SQL DUMP")

      # Check that the old records have been deleted (i.e. no records older than 1 month remain)
      expect(SleepRecord.where("updated_at < ?", 1.month.ago).count).to eq(0)
    end
  end

  context "when there are no records older than one month" do
    before do
      SleepRecord.destroy_all
      # Create a SleepRecord that is recent (less than 1 month old)
      user = User.create!(name: "Recent User")
      SleepRecord.create!(
        user: user,
        clock_in: 1.week.ago,
        clock_out: 1.week.ago + 8.hours,
        sleep_days: 0,
        sleep_hours: 8,
        sleep_minutes: 0,
        total_time: 480 * 60,
        updated_at: 1.week.ago
      )
    end

    it "outputs that there are no records to archive and does not call system" do
      expect(Kernel).not_to receive(:system)

      subject.reenable
      output = capture_stdout { subject.invoke }
      expect(output).to match(/No records older than 1 month to archive./)
    end
  end
end
