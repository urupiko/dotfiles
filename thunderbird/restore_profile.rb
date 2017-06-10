require 'rubygems'
require 'bundler/setup'
require 'inifile'
require 'zip'

require 'rbconfig'


# OSをチェックしてprofileの読み込み
# => 関数化が必要
# 引数にProfileを指定したものを読み込む（できればtar化したもの）
# profiles.iniの内容を書き換える
# 一度読み込んでみる
# メールの内容を精査する。いらないものは捨てる
# おまけ
# usage追加
# profiles.iniの内容をチェックする機能も欲しい

if ARGV.size < 2
  puts "Usage: ruby #{$0} source.zip target_full_dir"
  exit 1
end

def getIniFilePath
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

source_zip = ARGV[0]
target_dir = ARGV[1]

inifile = IniFile.load(getIniFilePath)
raise "File not found: "+inipath  if inifile.nil?
raise "Cannot find Profile0" unless inifile.has_section?('Profile0')

# Unzip
Zip::File.open(source_zip) do |zip_file|
  zip_file.each do |entry|
    puts "Extracting #{entry.name}"
    entry.extract(File.join(target_dir, entry.name))
  end
end


begin
  section = 'Profile0'
  p inifile[section]['Name']
  p inifile[section]['IsRelative']
  p inifile[section]['Path']

#  inifile[section]['IsRelative'] = 0
#  inifile[section]['Path'] = ARGV[1]
#  inifile.write()
rescue
  raise "Failed to access item(s)"
end
