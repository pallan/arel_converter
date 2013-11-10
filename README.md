# ArelConverter

[![Build Status](https://travis-ci.org/pallan/arel_converter.png?branch=master)](https://travis-ci.org/pallan/arel_converter)

This gem add the 'arel_convert' command to your system. When run against
a directory (or a single file) it will find and convert scopes,
associations and ActiveRecord finders into Rails 4 compatible Arel
syntax using Ruby 1.9 array syntax where appropriate. As you may expect
it works best under >=1.9 (development and testing was done under 2.0).

Here are some examples of what is converted,

```ruby
scope :active, :conditions => {:active => true}, :order => 'created_at'
# becomes
scope :active, -> { where(active: true).order('created_at') }

Model.find(:all, :conditions => ['name = ?', params[:term]], :limit => 5)
# becomes
Model.where('name = ?', params[:term]).limit(5)

has_many :articles, :class_name => "Post", :order => 'updated_at DESC'
# becomes
has_many :articles, -> { order('updated_at DESC') }, class_name: "Post"
```

The converters use Ruby2Ruby and RubyParser to convert to and translate
s-expressions. This ensures the code is converter back into valid Ruby
code. String parsing just doesn't work as well.

There are 3 converters,

### Scope

Converts 'scope' statements into the updated Rails 4 syntax, i.e.
wrapped in a lambda, with pre-Arel options converted to Arel

### Associations

Updates associations to use the updated Rails 4 syntax, i.e. wrapped in
lambdas where necessary. Assocation types handled are,

* belongs_to
* has_one
* has_many
* has_and_belongs_to_many

### Finders

Updates old ActiveRecord (pre Rails 3) syntax into Arel syntax of
chained Relations. This handles the following, including chained calls,

* Object.find(:all
* Object.find(:first
* Object.find.*:conditions
* Object.all(
* Object.first(


## Installation

Add this line to your application's Gemfile:

    gem 'arel_converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arel_converter

## Usage

    $ arel_convert [all,scope,association,finder] [PATH]

## Notes/Warnings/Recommendations

As with any software that could potentially update a wide swath of your
codebase in one (terrible) moment, it is recommended that you are
operating under some form of source control or have a reliable backup.

The converters doesn't play well with multiline code blocks. This means
that the parser will encounter a Exception (likely SyntaxError) when
processing the first line. This is because the matching code is a simple
grep of the file. Therefore, it would only grab the first line of a
multiline statement. The good news is that these exceptions will show up
in the results.

If your tests/specs are good then everything should still pass. If your
tests/specs are coupled to ActiveRecord finders then alot of them are
going to break. The converters make no attempt to update tests/specs at
this time. I've toyed with it and didn't get very far.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# License

### This code is free to use under the terms of the MIT license.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
