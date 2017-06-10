#! /usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'zip'
require 'inifile'

require 'rbconfig'

if ARGV.size < 1
  puts "Usage: ruby #{$0} zipfile"
  exit 1
end

def get_inifile_path
  case RbConfig::CONFIG['host_os']
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    return ENV['APPDATA']+'/Thunderbird/profiles.ini'
  when /darwin|mac os/
    return ENV['HOME']+'/Library/Thunderbird/profiles.ini'
  else
    raise "unsupported platform.."
    return nil
  end
end

def get_profile_path
  inifile_path = get_inifile_path
  puts "load inifile : #{inifile_path}"

  inifile = IniFile.load(inifile_path)
  raise "File not found: "+inipath  if inifile.nil?
  raise "Cannot find Profile0" unless inifile.has_section?('Profile0')

  target_dir = nil
  begin
    if (inifile['Profile0']['IsRelative'] == 0) 
      target_dir = inifile['Profile0']['Path']
    else
      target_dir = ::File.join(::File.dirname(inifile_path), 
                      inifile['Profile0']['Path'])
    end
  rescue
    raise "Failed to read the inifile"
  end

  return ::File.join(target_dir, ::File::ALT_SEPARATOR || ::File::SEPARATOR)
end

def zip_profile(source_dir, zip_path)
  source_dir.gsub!(::File::ALT_SEPARATOR) { ::File::SEPARATOR }
  puts "zipping profile : #{source_dir}"

  source_files = Dir.glob("#{source_dir}**/*")
  Zip.default_compression = Zlib::NO_COMPRESSION
  Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
    source_files.each do |long_path|
      short_path = long_path.dup
      short_path.slice!(source_dir)
      stat = ::File.stat(long_path)
      entry = ::Zip::Entry.new(zipfile.name, short_path, 
                nil, nil, nil, nil, nil, nil, ::Zip::DOSTime.at(stat.mtime))
      zipfile.add(entry, long_path)
    end
  end

  puts "Finished zipping : #{zip_path}"
end

zippath = ARGV[0]

zip_profile(get_profile_path, zippath)
