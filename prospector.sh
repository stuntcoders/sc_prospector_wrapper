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


if [ -f ~/.prospector ]; then
    source ~/.prospector
else
	echo "$(red)Missing configuration file with API keys$(normalize)"
	exit 1
fi


echo "-------- $1 --------" >> output.csv

curl --silent "https://company.clearbit.com/v2/companies/find?domain=$1" -u sk_3834ce4423aff86edde12dd2e9789f2d: | jq -r '{employees: .metrics.employeesRange, rev: .metrics.estimatedAnnualRevenue}' >> output.csv

curl --silent "https://api.hunter.io/v2/domain-search?domain=$1&api_key=$HUNTER_KEY" | jq -r '.data.emails' | in2csv -f json | csvcut -c value,type,confidence >> output.csv

