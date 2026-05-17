#!/bin/bash
export PATH=$PATH:$HOME/go/bin
BUG_BOUNTY_DIR="~/bugbounty"

find "$BUG_BOUNTY_DIR" -type f -name "subs.txt" | parallel  -j 4 --bar '
		SUBS_FILE={}
		DOMAIN_DIR=$(dirname "$SUBS_FILE")
		DOMAIN=$(basename "$DOMAIN_DIR")
		NUCLEI_OUT="$DOMAIN_DIR/nuclei_out.txt"
		
		echo "[+] Iniciando Vuln Recon para $DOMAIN"
		
		nuclei -l "$SUBS_FILE" -severity high,critical | anew "$NUCLEI_OUT" | notify -id vulns
	'
