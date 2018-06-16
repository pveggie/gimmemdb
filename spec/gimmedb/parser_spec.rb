RSpec.describe Gimmemdb::Parser do
  let(:parser) { Gimmemdb::Parser.new }
  let(:browser) { parser.browser }

  it "connects to the Tolino webreader webside" do
    expect(browser.url).to include("webreader.mytolino")
  end

  describe "Country select page" do
    it "promts the user to choose a language" do
      country_select_prompt = browser.div(class: 'country-container')
      expect(country_select_prompt.html).to include("Bitte wählen Sie Ihr Land aus:")
    end

    it "takes user to vendor page after language is selected" do
      parser.choose_language
      expect(browser.body.text).to_not include("Bitte wählen Sie Ihr Land aus:")
    end
  end

  describe "Vendor select page" do
    it "prompts the user to choose a vendor" do
      parser.choose_language
      browser.div(class: "reseller-container").wait_until_present
      expect(browser.body.text).to include("Bitte wählen Sie Ihren Buchhändler")
    end

    it "redirects to webreader dashboard on vendor selection" do
      parser.choose_language
      parser.choose_vendor
      browser.div(class: "sidebar-menu-login").wait_until_present
      expect(browser.body.text).to_not include("Bitte wählen Sie Ihren Buchhändler")
    end
  end

  describe "Webreader dashboard" do
    it "has login functionality" do
      parser.choose_language
      parser.choose_vendor
      browser.div(class: "sidebar-menu-login").wait_until_present
      expect(browser.div(class: "sidebar-menu-login").html).to include("Anmelden")
    end

    it "can be logged into" do
      parser.choose_language
      parser.choose_vendor
      parser.login
      browser.div(class: "sidebar-menu-login").wait_until_present
      expect(browser.div(class: "sidebar-menu-login").html).to include("Angemeldet")
    end
  end

  describe "Library" do
    before(:each) { parser.open_library }
    
    it "contains a list of books" do
      books = browser.div(class: "cover-grid-fixer")
      expect(books.html).to include("publication-details")
    end

    it "allows the user to select a book" do
      parser.open_book(SECRETS[:book_name])
    end
  end

  describe "Book" do
    it "reads the book" do
      parser.open_library
      parser.open_book(SECRETS[:book_name])
      parser.read_book
      expect(parser.book_pages).to_not be_empty
    end
  end
end
