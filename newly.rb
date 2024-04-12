#!/usr/bin/ruby

require 'net/http'
require 'thor'

class Newly < Thor
  desc "get URL", "Performs a GET request to the specified URL"
  option :headers, aliases: '-H', type: :array, desc: "Additional headers as 'Key: Value' pairs"
  option :cookies, aliases: '-C', type: :array, desc: "Additional cookies as 'Cookie: Value' pairs"

  def get(url)
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri)
    request['Cookie'] = String

    add_headers(request, options[:headers]) if options[:headers]
    add_cookies(request, options[:cookies]) if options[:cookies]

    response = http.request(request)

    puts("URL: ".dark_red + "#{uri} #{response.code} #{response.message}\n\n")

    response.each_header do |header, value|
      puts("#{header.capitalize.dark_red}: #{value.dark_blue}")
    end

    puts("\n" + response.body)
  end

  private

  def add_headers(request, headers)
    headers.each do |header|
      key, value = header.split(':')
      request[key.strip] = value.strip
    end
  end

  def add_cookies(request, cookies)
      request['Cookie'] = cookies.join('; ') if cookies
  end

end

class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
  end

  def dark_red
    "\e[31;1m#{self}\e[0m"
  end

  def dark_green
    "\e[32;1m#{self}\e[0m"
  end

  def dark_magenta
    "\e[35;1m#{self}\e[0m"
  end

  def dark_blue
    "\e[34;1m#{self}\e[0m"
  end

  def dark_cyan
    "\e[36;1m#{self}\e[0m"
  end

  def dark_yellow
    "\e[33;1m#{self}\e[0m"
  end
end

Newly.start(ARGV)
