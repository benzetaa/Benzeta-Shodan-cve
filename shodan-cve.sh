#!/bin/bash

# Seta as cores 
RED='\033[0;31m' # Red
NC='\033[0m' # No Color
VERDE='\033[0;32m' # Green 
LAZUL='\e[96m' # Ligth Blue 
BOLD='\e[1m' # Bold 
AMARELO='\033[1;33m'
AZUL='\033[1;34m'
# Seta as cores 


if [ -z $1 ] 
then 
    printf "\n${BOLD}Twitter: https://twitter.com/CapuzSec${NC} \n"
    printf "${BOLD}${AMARELO}Use ./shodan-cve.sh target.com${NC}\n\n" 
else 
    printf "\n${BOLD}Twitter: https://twitter.com/CapuzSec${NC} \n"
    rm *.result > /dev/null 2>&1

    if [ ! -d  results ];then mkdir results; fi
    if [ ! -d  results/${1} ];then mkdir results/${1}; fi
    
        printf "${BOLD}${AMARELO}\n[+] Scanning ${1}...${NC}\n"  
        curl -s "https://crt.sh/?q=%25.${1}&output=json" | jq -r '.[].name_value' | sort -u  >> results/${1}/${1}-result
        curl -s "https://dns.bufferover.run/dns?q=.${1}" | jq -r .FDNS_A[] | sed -s 's/,/ /g'  | sort -u  | awk '{ print $2 }' >> results/${1}/${1}-result
        
        printf "${BOLD}${AMARELO}[+] Creating IPs${NC}\n"
        for i in $(cat results/${1}/${1}-result | sort -u); do
            ping -c1 $i | head -n1 | awk '{ print $3 }' | sed -e 's/[()]//g' >> results/${1}/${1}-ip-result
        done
        for i in $(cat results/${1}/${1}-ip-result); do shodan host $i >> results/${1}/${1}-shodan-result; done

        printf "${BOLD}${RED}[+] Vulnerable to CVE ${NC}\n"    
        cat results/${1}/${1}-shodan-result | grep Vulnerabilities | sort -u      
fi