# Generate Test Files Script

Generates test export files with unique CPNP reference numbers. The files will all be the same apart from their reference number, copied from the reference data

## Requirements
`zip` - Run `sudo apt install -y zip` to install

## Usage
Called without any arguments, the script generates 10 files
```./generate-test-files.sh```
Called with a number as an argument, the script generates that number of test files.
```./generate-test-files.sh 100```
