require 'spec_helper'

describe Html::Pipeline::Hashtag do
  describe '.hashtags_in' do
    def extract_hashtags(text, context = {})
      tags = []

      filters = [
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::HashtagFilter
      ]

      pipeline = HTML::Pipeline.new filters
      result = pipeline.call text, context

      result[:hashtags]
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
          extract_hashtags("Hello ##{valid_tag}! ##{invalid_tag}", hashtag_pattern: custom_pattern)
        ).to eq([valid_tag])
      end
    end
  end

  describe '.call' do
    def filter(html, context = {})
      filters = [
        HTML::Pipeline::HashtagFilter
      ]

      pipeline = HTML::Pipeline.new filters
      pipeline.call(html, context)
    end

    def doc(html, context = {})
      filter(html, context)[:output]
    end

    context "should filtering plain text" do
      let(:tag) { 'world' }
      let(:html) { "<p>Hello ##{tag}!</p>" }

      [
        ['default', nil], ['custom', "/tags/%{tag}"]
      ].each do |title, tag_url|

        it "should filtering plain text with #{title} context" do
          url = (tag_url || "/tags/%{tag}") % { tag: tag }

          expect(url).to eq doc(html).search('a').attr('href').value
        end
      end
    end

    context 'should not replacing hashtag in' do
      it "links and styles" do
        html = '<a href="/">Hello <span style="color: #red">#magic</span> #world!</a>'
        expect( doc(html).search('a').count ).to eq(1)
      end

      it "code-tags" do
        html = '<code>Hello <span>#magic</span> #world!</code>'
        expect( doc(html).search('a') ).to be_empty
      end

      it 'pre-tags' do
        html = '<pre>Hello <span>#magic</span> #world!</pre>'
        expect( doc(html).search('a') ).to be_empty
      end
    end
  end
end
