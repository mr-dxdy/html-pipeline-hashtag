require 'spec_helper'

describe Html::Pipeline::Hashtag do
  describe '.hashtags_in' do
    def extract_hashtags(*args)
      tags = []
      HTML::Pipeline::HashtagFilter.hashtags_in(*args) { |hashtag, tag| tags << tag }

      tags
    end

    context "extracts latin/numeric hashtags" do
      %w(text text123 123text).each do |hashtag|
        it "should extract ##{hashtag}" do
          expect( extract_hashtags("##{hashtag}") ).to eq([hashtag])
        end

          it "should extract ##{hashtag} within text" do
            expect( extract_hashtags("pre-text ##{hashtag} post-text") ).to eq([hashtag])
          end
      end
    end

    context "international hashtags" do
      context "should allow accents" do
        %w(Россия mañana café münchen).each do |hashtag|
          it "should extract ##{hashtag}" do
            expect( extract_hashtags("##{hashtag}") ).to eq([hashtag])
          end

          it "should extract ##{hashtag} within text" do
            expect( extract_hashtags("pre-text ##{hashtag} post-text") ).to eq([hashtag])
          end
        end
      end
    end

    it 'should extract hashtag followed by punctuations' do
      expect( extract_hashtags("#test1: #test2; #test3\"") ).to eq(["test1", "test2" ,"test3"])
    end

    context "custom hashtag pattern" do
      let(:custom_pattern) { /#([\p{L}\w\-]{5})/ }

      it "should extract hashtag length of 5 characters" do
        valid_tag = "world"
        invalid_tag = "WWW"

        expect(
          extract_hashtags("Hello ##{valid_tag}! ##{invalid_tag}", custom_pattern)
        ).to eq([valid_tag])
      end
    end
  end

  describe '.call' do
    def filter(html, context = {})
      HTML::Pipeline::HashtagFilter.new(html, context).call.to_s
    end

    context "should filtering plain text" do
      let(:tag) { 'world' }
      let(:html) { "<p>Hello #%{tag}!</p>" }
      let(:result) { "<p>Hello %{link}!</p>" }

      [
        ['default', nil], ['custom', "/tags/%{tag}"]
      ].each do |title, tag_url|

        it "should filtering plain text with #{title} context" do
          url_pattern = tag_url || "/tags/%{tag}"
          link_pattern = "<a href=\"%{url}\" target=\"_blank\" class=\"hashtag\">#%{tag}</a>"

          url = url_pattern % { tag: tag }
          link = link_pattern % { url: url, tag: tag }

          puts result % { link: link }

          expect(
            filter(html % { tag: tag }, tag_url: tag_url)
          ).to eq(result % { link: link })
        end
      end
    end

    %w(pre code style a).each do |tag|
      it "should not replacing hashtag in #{tag} tags" do
        html = "<#{tag}>Hello #world!</#{tag}>"
        expect( filter(html) ).to eq(html)
      end
    end
  end
end
