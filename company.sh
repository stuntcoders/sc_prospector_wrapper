#!/bin/bash

# Echo in bold font if stdout is a terminal
ISTTY=0; if [ -t 1 ]; then ISTTY=1; fi
bold ()      { if [ $ISTTY -eq 1 ]; then tput bold;     fi; }
red ()       { if [ $ISTTY -eq 1 ]; then tput setaf 1;  fi; }
green ()     { if [ $ISTTY -eq 1 ]; then tput setaf 2;  fi; }
yellow ()    { if [ $ISTTY -eq 1 ]; then tput setaf 3;  fi; }
cyan ()      { if [ $ISTTY -eq 1 ]; then tput setaf 6;  fi; }
normalize () { if [ $ISTTY -eq 1 ]; then tput sgr0; fi; }

echo_bold ()      { echo -e "$(bold)$1$(normalize)"; }
echo_underline () { echo -e "\033[4m$1$(normalize)"; }
echo_color ()     { echo -e "$2$1$(normalize)"; }

function echo_title {

    title=$1
    length=$((${#title}+30))

    echo ""
    for i in {1..3}
    do
        if [ $i = 2 ]; then

            echo_bold "-------------- $title --------------"

        else
            COUNTER=0
            output=""
            while [  $COUNTER -lt $length ]; do
                output="$output-"
                COUNTER=$(($COUNTER + 1))
            done
            echo_bold $output
        fi
    done
    printf "\n\n"

}

source ~/.prospector

curl "https://company.clearbit.com/v2/companies/find?domain=$1" -u $CLEARBIT_KEY | jq -r '.metrics' | in2csv -f json >> output.csv

curl "https://api.hunter.io/v2/domain-search?domain=$1&api_key=$HUNTER_KEY" | jq -r '.data.emails' | in2csv -f json | csvcut -c value,type,confidence >> output.csv

