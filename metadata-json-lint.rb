#!/usr/bin/env ruby

require "json"

if ARGV[0].nil?
  abort("Error: Must provide a metadata.json file to parse")
end

metadata = ARGV[0]

f = File.read(metadata)

begin
  JSON.parse(f)
rescue
  abort("Error: Unable to parse json. There is a syntax error somewhere.")
end



