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


SCRIPT=${0##*/}

USAGE="\
Prospector by $(green)StuntCoders doo$(normalize)

 ____________
< prospector >
 ------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

Global Commands:
  $SCRIPT <command> [<options>]
--------------------------------------------------------------------------
  $(green)help$(normalize)                                List commands with short description
  $(green)update$(normalize)                              Updates Prospector to latest version
  $(green)version-check$(normalize)                       Check if latest version is used

  $(green)export domain.com$(normalize)                   Export data about single domain
  $(green)process filename.csv$(normalize)                Processes whole list of domains from CSV file (CSV should contain only domains)
  $(green)enrich filename.csv$(normalize)                 Enrich emails from csv (CSV should contain only emails)
"

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

function check_for_update() {
    curl --silent https://raw.githubusercontent.com/stuntcoders/sc_prospector_wrapper/master/prospector.sh > __companyupdate.temp

    if ! diff $0 "__companyupdate.temp" > /dev/null ; then
        echo "$(red)New version available$(normalize)"
        echo "Run \"$(green)prospector update$(normalize)\" to update to latest version"
    else
        echo "You have latest version of prospector"
    fi

    sudo rm -r __companyupdate.temp
}

function self_update() {
    sudo rm -f prospector.sh /usr/local/bin/prospector
    wget https://raw.githubusercontent.com/stuntcoders/sc_prospector_wrapper/master/prospector.sh
    sudo chmod +x ./prospector.sh
    sudo mv ./prospector.sh /usr/local/bin/prospector

    echo "$(green)Prospector updated to latest version — yaaay!$(normalize)"
    exit 0
}

COMMAND=$1

if [ -f ~/.prospector ]; then
    source ~/.prospector
else
	echo "$(red)Missing configuration file with API keys$(normalize)"
	exit 1
fi

if [ "$COMMAND" = "help" ]; then
    clear; echo -e "$USAGE";
fi

if [ "$COMMAND" = "version-check" ]; then
    check_for_update
fi

if [ "$COMMAND" = "update" ]; then
    self_update
fi

if [ "$COMMAND" = "export" ]; then
    echo "-------- $2 --------" >> output.csv
    curl --silent "https://company.clearbit.com/v2/companies/find?domain=$2" -u $CLEARBIT_KEY | jq -r '{employees: .metrics.employeesRange, rev: .metrics.estimatedAnnualRevenue} | to_entries[] | [.key, .value] | @csv' >> output.csv
    curl --silent "https://api.hunter.io/v2/domain-search?domain=$2&api_key=$HUNTER_KEY" | jq -r '.data.emails' | in2csv -f json | csvcut -c value,type,confidence >> output.csv
fi

if [ "$COMMAND" = "process" ]; then
    echo "Might take some time, please be patient..."

    while IFS='' read -r domain || [[ -n "$domain" ]]; do
        eval "bash $0 export $domain"
    done < "$2"

    echo "Done. Run '$(green)open output.csv$(normalize)' to see results."
fi

if [ "$COMMAND" = "enrich" ]; then
    echo "I am stupid slow computer... please be patient ;)"

    echo "Email,Given name,Family name,Linkedin,Company name,Industry category,Founded year,Facebook,Fb likes" > enrich_output.csv

    while IFS='' read -r email || [[ -n "$email" ]]; do
        echo -n "$email," >> enrich_output.csv
        curl --silent "https://person-stream.clearbit.com/v2/combined/find?email=$email" -u $CLEARBIT_KEY | jq -r '{givenName: .person.name.givenName, familyName: .person.name.familyName, linkedin: .person.linkedin.handle, companyName: .company.name, industry: .company.category.industryGroup, foundedYear: .company.foundedYear, facebook: .company.facebook.handle, fbLikes: .company.facebook.likes} | to_entries[]' | jq .'value' | tr '\n' ',' >> enrich_output.csv
        echo "" >> enrich_output.csv
    done < "$2"

    echo "Done. Run '$(green)open enrich_output.csv$(normalize)' to see results."
fi
