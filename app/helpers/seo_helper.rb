module SeoHelper
  def page_title
    base = t("app.name")
    custom = content_for(:title)
    custom && custom != base ? custom : "#{base} — #{t('app.tagline')}"
  end

  def json_ld_software_application
    {
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => "Ronaitre",
      "applicationCategory" => "HealthApplication",
      "operatingSystem" => "Web",
      "description" => t("app.tagline"),
      "url" => request.base_url,
      "inLanguage" => "fr-FR",
      "offers" => { "@type" => "Offer", "price" => "0", "priceCurrency" => "EUR" }
    }
  end

  def json_ld_organization
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "Ronaitre",
      "url" => request.base_url,
      "logo" => "#{request.base_url}/icon.png",
      "email" => "contact@ronaitre.example"
    }
  end

  def json_ld_faq
    items = t("landing.faq.items").map do |item|
      {
        "@type" => "Question",
        "name" => item[:question],
        "acceptedAnswer" => { "@type" => "Answer", "text" => item[:answer] }
      }
    end
    {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => items
    }
  end

  def render_json_ld(*objects)
    payload = objects.size == 1 ? objects.first : { "@graph" => objects }
    tag.script(JSON.pretty_generate(payload).html_safe, type: "application/ld+json")
  end
end
