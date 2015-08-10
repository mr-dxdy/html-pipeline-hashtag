# Hashtag filter for html-pipeline

An [HTML::Pipeline](https://github.com/jch/html-pipeline) filter for [hashtags](https://en.wikipedia.org/wiki/Hashtag).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html-pipeline-hashtag'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html-pipeline-hashtag

## Usage

Example:

```ruby
require 'html/pipeline'
require 'html/pipeline/hashtag/hashtag_filter'

filters = [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::HashtagFilter
]

pipeline = HTML::Pipeline.new filters

input = "Hello #world!"

context = {
  :tag_url => '/tags/%{tag}'
}

result = pipeline.call(input, context)

puts result[:output].to_html
# => "<p>Hello <a href=\"/tags/world\" target=\"_blank\" class=\"hashtag\">#world</a>!</p>\n" 

puts result[:hashtags]
# => ["world"]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mr-dxdy/html-pipeline-hashtag.

