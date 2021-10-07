# symplectic-elements-utils
**Command-line utilities for the Symplectic Elements API implemented in Ruby**

## Getting Started

```bash
$ bundle install
```

## Usage

### CSV / XML Processing
**This transforms CSV data sets into XML REST requests**

```bash
$ bundle exec thor elements:csv:transform --xml-export=XML_EXPORT --csv-import=CSV_IMPORT
```

### Elements API

#### User Feeds

```bash
$ bundle exec thor elements:user_feeds:create \
  --host=HOST \
  --port=PORT \
  --endpoint=ENDPOINT \
  --password=PASSWORD \
  --username=USERNAME \
  --id=ID \
  --xml-request=XML_REQUEST
```

## Development

### Run the test suites

```bash
$ bundle exec rspec
```
