require "yaml"
require "net/https"
require "json"
require "pry"

lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir)

require "auth"
require "request_client"
require "submission_batch"
require "contribution_uploader"
require "contribution"

CREDENTIALS = YAML.load_file("authentication.yml")

puts "Obtaining Getty OAuth2 token..."
token = Auth.token

puts "Creating Submission Batch..."
submission_batch = SubmissionBatch.new(token)
batch = submission_batch.create("test batch", "getty_editorial_still")

directory = File.join(File.dirname(__FILE__), "/sample_images")
files = Dir["#{directory}/*.jpg"]

puts "Uploading files..."
contribution_ids = []
files.each do |file_path|
  file = File.new(file_path)
  file_name = File.basename(file_path)
  uploader = ContributionUploader.new(file, "image/jpeg", batch[:id], token)
  contribution_id = uploader.upload("virginia", file_name)
  contribution_ids << contribution_id
end

puts "Waiting for image metadata extraction"
sleep 60

puts "Updating and publishing image contributions"
contribution_ids.each do |contribution_id|
  contribution = Contribution.new(token, contribution_id, batch[:id])

  metadata = {
    "content_provider_name" => "MPI Media",
    "content_provider_title" => "Contributor",
    "country_of_shoot" => "United States",
    "created_date" => "1996-08-12",
    "credit_line" => "Some credit line",
    "headline" => "My great headline",
    "iptc_category" => "S",
    "iptc_subjects" => ["Stuff to Do in the USA"],
    "parent_source" => "Getty Images",
    "site_destination" => ["Editorial"],
    "source" => "Globo"
  }
  contribution.update(metadata)
  contribution.submit
  puts contribution.get.inspect
end
