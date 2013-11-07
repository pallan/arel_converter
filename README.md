# ArelConverter

This gem add the 'arel_convert' command to your system. When run against
a directory (or a single file) it will find and convert scopes,
associations and ActiveRecord finders into Rails 4 compatible Arel
syntax using Ruby 1.9 array syntax where appropriate.  For example,

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


## Installation

Add this line to your application's Gemfile:

    gem 'arel_converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arel_converter

## Usage

    $ arel_convert [all,scope,association,finder]  

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
