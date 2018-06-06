require 'mechanize'
require 'watir'
require 'headless'
require 'webdrivers'
require_relative '../../login'

module Gimmemdb
  # connects to webreader and parses data
  class Parser
    attr_reader :browser

    def initialize(attr={})
      @url = attr[:url] || "https://webreader.mytolino.com/library/index.html"
      @browser = Watir::Browser.new :firefox, headless: true
      @browser.goto @url
    end

    def choose_language
      @browser.div(text: "Deutschland").wait_until_present.fire_event :click
    end

    def choose_vendor
      @browser.div(class: "reseller-container").wait_until_present
      @browser.element(title: "MeineBUCHhandlung").fire_event :click
    end

    def login
      @browser.div(class: "sidebar-menu-login").wait_until_present
      @browser.button(text: "Anmelden").fire_event :click
      email = SECRETS[:email].strip
      password = SECRETS[:password].strip
      
      form = @browser.form.wait_until_present
      form.text_field(id: "login-email").set(email)
      form.text_field(id: "login-password").set(password)
      form.button.click
    end

    def open_library
      choose_language
      choose_vendor
      login
      @browser.div(text: "Meine Bücher").fire_event :click
    end
  end
end
