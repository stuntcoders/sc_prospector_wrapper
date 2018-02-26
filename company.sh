#!/bin/bash

source ~/.prospector

curl "https://company.clearbit.com/v2/companies/find?domain=$1" -u $CLEARBIT_KEY | jq -r '.metrics' | in2csv -f json >> output.csv

curl "https://api.hunter.io/v2/domain-search?domain=$1&api_key=$HUNTER_KEY" | jq -r '.data.emails' | in2csv -f json | csvcut -c value,type,confidence >> output.csv

