require "yaml"
require "net/https"
require "json"
require "auth"
require "request_client"
require "submission_batch"
require "contribution_uploader"

lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir)
CREDENTIALS = YAML.load_file("authentication.yml")

token = Auth.token

submission_batch = SubmissionBatch.new(token)
batch = submission_batch.create("test batch", "getty_editorial_still")
directory = File.join(File.dirname(__FILE__), "/sample_images")
files = Dir["#{directory}/*.jpg"]

contribution_ids = []
files.each do |file_path|
  file = File.new(file_path)
  file_name = File.basename(file_path)
  uploader = ContributionUploader.new(file, "image/jpeg", batch[:id], token)
  contribution_id = uploader.upload("virginia", file_name)
  contribution_ids << contribution_id
end
