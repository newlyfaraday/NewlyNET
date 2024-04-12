#!/usr/bin/ruby

require 'net/http'
require 'thor'

class Newly < Thor
  desc "get -U URL", "Performs a GET request to the specified URL"

  class_option :url, aliases: '-U', type: :string, desc: "URL for perform request"
  class_option :output_save, aliases: "-S", type: :string, desc: "File to save the output"
  class_option :url_list, aliases: "-S", type: :string, desc: "Set multi url list path"
  class_option :output, aliases: "-O", type: :string, desc: "Output to be printed on the screen"
  class_option :headers, aliases: '-H', type: :array, desc: "Additional headers as 'Key: Value' pairs", required: false
  class_option :cookies, aliases: '-C', type: :array, desc: "Additional cookies as 'Cookie: Value' pairs", required: false
  class_option :open_timeout, type: :numeric, desc: "Additional open page timeout value", required: false
  class_option :read_timeout, type: :numeric, desc: "Additional read page timeout value", required: false

  def get()
    uri = URI(options[:url])

    request = Net::HTTP::Get.new(uri)
    http(uri, request)
  end

  desc "post URL", "Performs a POST request to the specified URL"
  option :post_data, type: :array, desc: "Data to send for post requets as ''"

  def post()
    uri = URI(options[:url])

    request = Net::HTTP::Post.new(uri)
    http(uri, request)
  end

  private

  def print_response(response, code, message)
    puts("URL: ".dark_red + "#{options[:url]} #{code} #{message}\n\n")

    response.each_header do |header, value|
      puts("#{header.capitalize.dark_red}: #{value.dark_blue}")
    end

    puts("\n" + response.body)
  end

  def http(uri, request)
    net_http = Net::HTTP.new(uri.host, uri.port)
    net_http.use_ssl = (uri.scheme == 'https')

    net_http.open_timeout = options[:open_timeout] if @options[:open_timeout]
    net_http.read_timeout = options[:read_timeout] if @options[:read_timeout]

    request['Cookie'] = String

    add_headers(request, options[:headers]) if options[:headers]
    add_cookies(request, options[:cookies]) if options[:cookies]

    response = net_http.request(request)
    print_response(response, response.code, response.message)
  end

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
