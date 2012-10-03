require 'rubygems'
require 'xcoder'
require 'github_api'

if File.exist?('Rakefile.config')
  load 'Rakefile.config'
end

$name="CocoaLumberjack"
$configuration="Release"

project=Xcode.project($name)
$iphone=project.target($name+"IOS").config($configuration).builder
$iphone.sdk = :iphoneos
$iphonesimulator=project.target($name+"IOS").config($configuration).builder
$iphonesimulator.sdk = :iphonesimulator
$osx=project.target($name+"OSX").config($configuration).builder
$osx.sdk = :macosx

desc "Clean, Build, Test and Archive for iOS and OS X"
task :default => [:ios, :osx]

desc "Cleans for iOS and OS X"
task :clean => [:removebuild, "ios:clean", "osx:clean"]

desc "Builds for iOS and OS X"
task :build => ["ios:build", "osx:build"]

desc "Test for iOS and OS X"
task :test => ["ios:test", "osx:test"]

desc "Archives for iOS and OS X"
task :archive => ["ios:archive", "osx:archive"]

desc "Remove build folder"
task :removebuild do
  rm_rf "build"
end

desc "Clean, Build, Test and Archive for iOS"
task :ios => ["ios:clean", "ios:build", "ios:test", "ios:archive"]

namespace :ios do  

  desc "Clean for iOS"
  task :clean => [:init, :removebuild] do
    $iphone.clean
    $iphonesimulator.clean
  end
  
  desc "Build for iOS"
  task :build => :init do
    $iphone.build
  end
  
  desc "Test for iOS"
  task :test => :init do
    puts("Tests for iOS are not implemented - hopefully (!) - yet.")
  end
  
  desc "Archive for iOS"
  task :archive => ["ios:clean", "ios:build", "ios:test"] do
    cd "build/" + $configuration + "-iphoneos" do
      sh "tar cvzf ../" + $name + "IOS.tar.gz *.framework"
    end
  end

end

desc "Clean, Build, Test and Archive for OS X"
task :osx => ["osx:clean", "osx:build", "osx:test", "osx:archive"]

namespace :osx do

  desc "Clean for OS X"
  task :clean => [:init, :removebuild] do
    $osx.clean
  end

  desc "Build for OS X"
  task :build => :init do
    $osx.build
  end
  
  desc "Test for OS X"
  task :test => :init do
    puts("Tests for OS X are not implemented - hopefully (!) - yet.")
  end

  desc "Archive for OS X"
  task :archive => ["osx:clean", "osx:build", "osx:test"] do
    cd "build/" + $configuration do
      sh "tar cvzf ../" + $name + "OSX.tar.gz *.framework"
    end
  end

end

desc "Initialize and update all submodules recursively"
task :init do
  system("git submodule update --init --recursive")
  system("git submodule foreach --recursive git checkout master")
end

desc "Pull all submodules recursively"
task :pull => :init do
  system("git submodule foreach --recursive git pull")
end

def publish(os = "IOS")
  github = Github.new :user => $github_username, :repo => $name, :login => $github_login, :password => $github_password
  file = 'build/' + $name + os + ".tar.gz"
  now = File.mtime(file)
  name = $name + os + '-' + now.strftime("%Y-%m-%d-%H-%M-%S") + '.tar.gz'
  size = File.size(file)
  description = 'Release from ' + now.strftime("%Y-%m-%d %H:%M:%S")
  res = github.repos.downloads.create $github_username, $name,
    "name" => name,
    "size" => size,
    "description" => description,
    "content_type" => "application/x-gzip"
  github.repos.downloads.upload res, file
end

desc "Publish the Frameworks to github"
task :publish do
  publish()
  publish("OSX")
end
