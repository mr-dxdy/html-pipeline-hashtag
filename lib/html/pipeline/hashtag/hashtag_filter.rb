require 'set'

require 'html/pipeline'

module HTML
  class Pipeline
    # HTML filter that replaces @hashtag with link. Hashtags within <pre>,
    # <code>, and <a> elements are ignored.
    #
    # Context options:
    #   :tag_url - Used to construct links to search by hashtag.
    #                  Example: http://localhost/search?q=%{tag}
    #   :hashtag_pattern - Used to provide a custom regular expression to
    #                      indentify hashtags
    #
    class HashtagFilter < Filter
      def self.hashtags_in(text, hashtag_pattern = HashtagPattern)
        text.gsub hashtag_pattern do |match|
          tag = $1
          yield match, tag
        end
      end

      HashtagPattern = /#([\p{L}\w\-]+)/

      IGNORE_PARENTS = %w(pre code a style).to_set

      def call
        result[:hashtags] ||= []

        doc.search('text()').each do |node|
          content = node.to_html

          next if !content.include?('#')
          next if has_ancestor?(node, IGNORE_PARENTS)

          html = hashtag_link_filter(content, hashtag_pattern)
          node.replace(html) unless html == content
        end

        doc
      end

      def tag_url
        context[:tag_url] || default_tag_url
      end

      def default_tag_url
        '/tags/%{tag}'
      end

      def hashtag_pattern
        context[:hashtag_pattern] || HashtagPattern
      end

      def hashtag_link_filter(text, hashtag_pattern)
        self.class.hashtags_in(text, hashtag_pattern) do |match, tag|
          result[:hashtags] |= [tag]

          link_to_hashtag(tag)
        end
      end

      def link_to_hashtag(tag)
        url = tag_url % { tag: tag }
        link_pattern % { url: url, tag: tag }
      end

      def link_pattern
        "<a href='%{url}' target='_blank' class='hashtag'>#%{tag}</a>"
      end
    end
  end
end
