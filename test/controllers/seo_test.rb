require "test_helper"

class SeoTest < ActionDispatch::IntegrationTest
  test "sitemap lists only indexable public pages" do
    get "/sitemap.xml"
    assert_response :success

    doc = Nokogiri::XML(@response.body)
    locs = doc.xpath("//xmlns:loc", "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9").map(&:text)

    assert_includes locs.join(" "), "/"
    assert_includes locs.join(" "), "/aidants"
    assert_includes locs.join(" "), "/csapa"
    assert_no_match %r{/auth}, locs.join(" ")
    assert_no_match %r{/avis}, locs.join(" ")
  end

  test "robots.txt exposes sitemap and blocks private areas" do
    get "/robots.txt"
    assert_response :success
    assert_match "Sitemap:", @response.body
    assert_match "Disallow: /connections", @response.body
    assert_match "Disallow: /helper", @response.body
  end

  test "llms.txt describes the product with public links" do
    get "/llms.txt"
    assert_response :success
    assert_match "# Ronaitre", @response.body
    assert_match "ne remplace pas", @response.body
    assert_match "/csapa", @response.body
  end

  test "home carries full seo head" do
    get root_path
    assert_response :success
    assert_select "html[lang=fr]"
    assert_select "meta[name=description]"
    assert_select "link[rel=canonical]"
    assert_select 'meta[property="og:image"]'
    assert_select 'meta[property="og:locale"]', content: "fr_FR"
    assert_select 'script[type="application/ld+json"]'
  end

  test "auth pages are noindexed" do
    get auth_path
    assert_select "meta[name=robots]", content: "noindex, nofollow"
  end

  test "app pages are noindexed via app layout" do
    user = User.create!(email_address: "seo@example.com", password: "motdepasse1")
    sign_in_as(user)
    get dashboard_path
    assert_select "meta[name=robots]", content: "noindex, nofollow"
  end

  test "legal pages have unique descriptions" do
    get confidentialite_path
    assert_select "meta[name=description]" do |el|
      assert_match "RGPD", el.first[:content]
    end
  end
end
