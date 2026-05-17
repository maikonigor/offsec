#!/bin/bash

export PATH=$PATH:$HOME/go/bin

BUG_BOUNTY_DIR="$HOME/bugbounty"

# Verifica se a flag --brute foi passada
ENABLE_BRUTE=false

if [[ "$1" == "--brute" ]]; then
    ENABLE_BRUTE=true
fi

find "$BUG_BOUNTY_DIR" -type f -name "domains.txt" | while read -r domain_path; do

    COMPANY_DIR=$(dirname "$domain_path")

    parallel -j 4 --bar "
        DOMAIN={}

        DOMAIN_DIR='$COMPANY_DIR/domains'/\$DOMAIN

        SUBS=\"\$DOMAIN_DIR/subs.txt\"

        BRUTE_DNS=\"\$DOMAIN_DIR/brute_dns.txt\"

        mkdir -p \"\$DOMAIN_DIR\"

        echo '[+] Iniciando recon para' \$DOMAIN

        subfinder -d \$DOMAIN -silent | anew \"\$SUBS\"

        if $ENABLE_BRUTE; then

            echo '[+] Executando shuffleDNS para' \$DOMAIN

            shuffledns \
                -d \$DOMAIN \
                -w /usr/share/wordlists/SecLists/Discovery/DNS/dns-Jhaddix.txt \
                -r /usr/share/wordlists/resolvers/resolvers.txt \
                -o \"\$BRUTE_DNS\" \
                -t 1000 \
                -mode bruteforce

            cat \"\$BRUTE_DNS\" | anew \"\$SUBS\"

        fi

    " :::: "$domain_path"

done
