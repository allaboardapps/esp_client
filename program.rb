require 'yaml'
require 'net/https'
require 'json'
require 'auth'
require 'request_client'

lib_dir = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH.unshift(lib_dir)
CREDENTIALS = YAML.load_file('authentication.yml')

token = Auth.token
