module RichText
  class Sanitize
    ALLOWED_TAGS = %w[
      p br strong b em i u s strike del
      h1 h2 h3 h4 h5 h6
      ul ol li blockquote hr
      a span code pre mark
    ].freeze

    ALLOWED_ATTRIBUTES = %w[href style target rel data-color].freeze

    ALLOWED_CSS = %w[
      color background-color font-size font-family
      font-weight text-align text-decoration
    ].freeze

    def self.call(html)
      new(html).call
    end

    def initialize(html)
      @html = html.to_s
    end

    def call
      return "" if @html.blank?

      fragment = Loofah.fragment(@html)
      fragment.css("img, picture, video, iframe, object, embed, svg, canvas, source, audio, script, style").remove
      fragment.css("*").each { |node| scrub_node(node) }

      sanitized = Rails::Html::SafeListSanitizer.new.sanitize(
        fragment.to_html,
        tags: ALLOWED_TAGS,
        attributes: ALLOWED_ATTRIBUTES
      ).to_s

      return "" if blank?(sanitized)

      sanitized
    end

    private

    def scrub_node(node)
      scrub_style(node)
      scrub_href(node)
      node.attribute_nodes.each do |attr|
        name = attr.name
        node.remove_attribute(name) if name.start_with?("on") || %w[src srcset poster].include?(name)
      end
    end

    def scrub_style(node)
      style = node["style"]
      return if style.blank?
      return node.remove_attribute("style") if dangerous_css?(style)

      declarations = style.split(";").filter_map do |declaration|
        property, value = declaration.split(":", 2)
        next if property.blank? || value.blank?

        property = property.strip.downcase
        value = value.strip
        next unless ALLOWED_CSS.include?(property)
        next if dangerous_css?(value)
        next unless safe_value?(property, value)

        "#{property}: #{value}"
      end

      if declarations.empty?
        node.remove_attribute("style")
      else
        node["style"] = declarations.join("; ")
      end
    end

    def scrub_href(node)
      return unless node.name == "a"

      href = node["href"].to_s.strip
      if href.match?(/\A(?:https?:\/\/|mailto:)/i)
        node["href"] = href
        node["rel"] = "noopener noreferrer"
        node["target"] = "_blank"
      else
        node.remove_attribute("href")
      end
    end

    def dangerous_css?(value)
      value.match?(/url\s*\(|expression\s*\(|image-set|javascript:|@import|-moz-binding/i)
    end

    def safe_value?(property, value)
      case property
      when "color", "background-color"
        value.match?(/\A(?:#[0-9a-f]{3,8}|rgba?\([^)]+\)|hsla?\([^)]+\)|[a-z]{3,20})\z/i)
      when "font-size"
        value.match?(/\A\d{1,3}(?:\.\d+)?(?:px|rem|em|%)\z/)
      when "font-family"
        value.match?(/\A[a-z0-9 ,'"\-]+\z/i)
      when "font-weight"
        value.match?(/\A(?:normal|bold|bolder|lighter|[1-9]00)\z/)
      when "text-align"
        value.match?(/\A(?:left|center|right|justify)\z/)
      when "text-decoration"
        value.match?(/\A(?:none|underline|line-through)\z/)
      else
        false
      end
    end

    def blank?(html)
      fragment = Loofah.fragment(html)
      fragment.text.gsub("\u00a0", " ").squish.blank? && fragment.at_css("hr").nil?
    end
  end
end
