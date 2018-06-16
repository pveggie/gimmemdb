require 'mechanize'
require 'watir'
require 'headless'
require 'webdrivers'
require_relative '../../login'

module Gimmemdb
  # connects to webreader and parses data
  class Parser
    attr_reader :browser, :book_pages

    def initialize(attr={})
      @url = attr[:url] || "https://webreader.mytolino.com/library/index.html"
      @browser = Watir::Browser.new :firefox, headless: true
      @browser.goto @url
      @book_pages = []
      @book = nil
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
      @browser.div(class: "sidebar-container-helper").wait_until_present
      @browser.div(class: "sidebar-menu-group-item-text", text: "Meine Bücher").fire_event :click
      @browser.div(class: "cover-grid-fixer").wait_until_present
    end

    def open_book(book)
      ap book
      book_title = @browser.div(text: book)
      book_title.parent.parent.div(class: "publication-cover-image").fire_event :click
    end

    def read_book
      @browser.iframe(class: "tolino-web-reader").wait_until_present
      
      #until last_page?
        @book_pages << read_page
        # next_arrow = @browser.div(class: "btn-prev-next", title: "Zum nächsten Abschnitt wechseln")
        # next_arrow.fire_event :click
      #end
    end

    def read_page
      @browser.iframe(class: "tolino-web-reader").body.div.wait_until_present
      iframes =  @browser.iframes(class: "tolino-web-reader")
      page_content = []

      iframes.each do |iframe|
        html_content = iframe.body.inner_html
        next if html_content.empty?
        page_content << parse_content(html_content)
      end

      page_content
    end

    def last_page?
      page_numbers = ""
      while page_numbers.empty?
        page_numbers = @browser.span(class: "page-numbers").text.split(" ")
      end

      page_numbers.first == page_numbers.last
    end

    def parse_content(html_content)
      content = Nokogiri::HTML(html_content)
      ap content
    end
  end
end
