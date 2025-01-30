# Contributing

## How to contribute

This gem uses [Appraisal](https:..//github.com/thoughtbot/appraisal) to test against multiple versions of Rails.

Some versions of Ruby are not supported using different versions of Rails. Checkout
the .github/workflows/ci.yml and Appraisals file to see which versions of Ruby are tested.

## Running tests

Install dependencies:

```bash
bundle install
bundle exec appraisal bundle install
```

Both Appraisals and ci.yml define what versions of Ruby and Rails are supported.

Run tests for all Rails versions supported for your Ruby version:

```bash
bundle exec appraisal bundle exec rake
```

Run tests against a specific version of Rails:

```bash
bundle exec appraisal rails_main bundle exec rake
```
