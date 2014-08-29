[![Gem Version](https://badge.fury.io/rb/chatbox.svg)](http://badge.fury.io/rb/chatbox)
[![Build Status](https://travis-ci.org/austinthecoder/chatbox.svg?branch=master)](https://travis-ci.org/austinthecoder/chatbox)
[![Code Climate](https://codeclimate.com/github/austinthecoder/chatbox/badges/gpa.svg)](https://codeclimate.com/github/austinthecoder/chatbox)

# Chatbox

Simple messaging system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chatbox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chatbox

## Usage

```ruby
Person = Struct.new :chatbox_id

austin = Person.new 1
rachel = Person.new 2

Chatbox.deliver_message! from: austin, to: rachel, body: 'Hello! How are you?'

rachels_inbox = Chatbox.fetch_inbox rachel
message = rachels_inbox[0]
message.body # 'Hello! How are you?'

austins_outbox = Chatbox.fetch_outbox austin
message = austins_outbox[0]
message.body # 'Hello! How are you?'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/chatbox/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
