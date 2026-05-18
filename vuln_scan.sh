#!/bin/bash
# scan.sh - Script de scanning de vulnerabilidades

# Usage: ./scan.sh <domain> <domain_dir>

DOMAIN="$1"
DOMAIN_DIR="$2"

LOG_FILE="$DOMAIN_DIR/logs/scan.log"
NUCLEI_DIR="$DOMAIN_DIR/scans/nuclei"
FFUF_DIR="$DOMAIN_DIR/scans/ffuf"

mkdir -p "$NUCLEI_DIR" "$FFUF_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Arquivos de entrada
ALIVE_FILE="$DOMAIN_DIR/alive.txt"
URLS_FILE="$DOMAIN_DIR/urls.txt"
PARAMS_FILE="$DOMAIN_DIR/parameters.txt"

log "=== Starting Vulnerability Scan for $DOMAIN ==="

# 1. Nuclei Scanning
log "[1/4] Running nuclei scans..."

if command -v nuclei &> /dev/null; then
    # Critical e High
    log "[*] Scanning critical/high vulnerabilities..."
    if command -v notify &> /dev/null; then
        nuclei -l "$ALIVE_FILE" -severity critical,high -silent -stats | tee "$NUCLEI_DIR/critical_high.txt" | notify -silent -id vulns 2>/dev/null
    else
        nuclei -l "$ALIVE_FILE" -severity critical,high -silent -stats -o "$NUCLEI_DIR/critical_high.txt"
    fi
    
    # Medium e Low
    # log "[*] Scanning medium/low vulnerabilities..."
    # nuclei -l "$ALIVE_FILE" \
    #     -severity medium,low \
    #     -silent \
    #     -o "$NUCLEI_DIR/medium_low.txt"
    
    # # Misconfigurations
    # log "[*] Scanning misconfigurations..."
    # nuclei -l "$ALIVE_FILE" \
    #     -tags misconfig \
    #     -silent \
    #     -o "$NUCLEI_DIR/misconfigs.txt"
    
    # # Exposure (open redirect, etc)
    # log "[*] Scanning exposures..."
    # nuclei -l "$ALIVE_FILE" \
    #     -tags exposure \
    #     -silent \
    #     -o "$NUCLEI_DIR/exposures.txt"
    
    # Count findings
    CRIT_COUNT=$(wc -l < "$NUCLEI_DIR/critical_high.txt" 2>/dev/null || echo "0")
    log "[✓] Found $CRIT_COUNT critical/high findings"
else
    log "[!] nuclei not found, skipping"
fi

# 2. XSS Scanning com Dalfox
log "[2/4] XSS scanning with gf and dalfox..."



if command -v dalfox &> /dev/null && [ -f "$PARAMS_FILE" ] && [ -s "$PARAMS_FILE" ]; then
    log "[*] Running dalfox on parameter endpoints..."
    
    # Pegar URLs com parâmetros
    grep -E '\?.*=' "$URLS_FILE" | head -100 > "$DOMAIN_DIR/urls_with_params.txt"

    # buscar urls com xss e preparar para o dalfox
    if command -v gf &> /dev/null; then
        cat "$DOMAIN_DIR/urls_with_params.txt"| gf xss | anew "$DOMAIN_DIR/xss.txt"
    else
        log "[*] gf not found, skipping XSS detection"
    fi
    
    if [ -s "$DOMAIN_DIR/xss.txt" ]; then
        if command -v notify &> /dev/null; then
            dalfox file "$DOMAIN_DIR/xss.txt" --silent --only-poc --timeout 10 | tee "$DOMAIN_DIR/dalfox_results.txt" | notify -silent -id vulns 2>/dev/null
        else
            dalfox file "$DOMAIN_DIR/xss.txt" --silent --only-poc --timeout 10 -o "$DOMAIN_DIR/dalfox_results.txt" 2>/dev/null
        fi
        
        XSS_COUNT=$(wc -l < "$DOMAIN_DIR/dalfox_results.txt" 2>/dev/null || echo "0")
        log "[✓] Found $XSS_COUNT potential XSS"
    fi
else
    log "[!] dalfox not found or no parameters found"
fi

# 3. Directory Fuzzing (apenas para domínios principais)
log "[3/4] Directory fuzzing..."

if command -v ffuf &> /dev/null; then
    # Fuzzing apenas no domínio principal e alguns subdomínios importantes
    head -5 "$ALIVE_FILE" | while read -r url; do
        DOMAIN_NAME=$(echo "$url" | sed 's|https\?://||' | cut -d'/' -f1)
        
        log "[*] Fuzzing: $DOMAIN_NAME"
        
        ffuf -u "$url/FUZZ" \
            -w /usr/share/wordlists/dirb/common.txt \
            -fc 404 \
            -t 30 \
            -c \
            -o "$FFUF_DIR/${DOMAIN_NAME}.json" \
            -of json \
            -s 2>/dev/null
        
        # Extrair resultados encontrados
        if [ -f "$FFUF_DIR/${DOMAIN_NAME}.json" ]; then
            cat "$FFUF_DIR/${DOMAIN_NAME}.json" | jq -r '.results[] | "\(.url) [\(.status)]"' 2>/dev/null \
                >> "$DOMAIN_DIR/found_directories.txt"
        fi
    done
    
    DIR_COUNT=$(wc -l < "$DOMAIN_DIR/found_directories.txt" 2>/dev/null || echo "0")
    log "[✓] Found $DIR_COUNT directories"
fi


# Criar relatório consolidado
cat > "$DOMAIN_DIR/VULN_REPORT.md" << EOF
# Vulnerability Scan Report - $DOMAIN

**Date:** $(date)
**Scanner:** Automated Bug Bounty Pipeline

## Executive Summary

| Severity | Count |
|----------|-------|
| Critical/High | $(wc -l < "$NUCLEI_DIR/critical_high.txt" 2>/dev/null || echo "0") |
| Medium/Low | $(wc -l < "$NUCLEI_DIR/medium_low.txt" 2>/dev/null || echo "0") |
| Potential XSS | $(wc -l < "$DOMAIN_DIR/dalfox_results.txt" 2>/dev/null || echo "0") |
| Directories Found | $(wc -l < "$DOMAIN_DIR/found_directories.txt" 2>/dev/null || echo "0") |

## Critical/High Findings
\`\`\`
$(cat "$NUCLEI_DIR/critical_high.txt" 2>/dev/null || echo "No critical findings")
\`\`\`

## XSS Potentials
\`\`\`
$(cat "$DOMAIN_DIR/dalfox_results.txt" 2>/dev/null || echo "No XSS found")
\`\`\`

## Discovered Directories
\`\`\`
$(cat "$DOMAIN_DIR/found_directories.txt" 2>/dev/null || echo "No directories found")
\`\`\`

## Misconfigurations
\`\`\`
$(cat "$NUCLEI_DIR/misconfigs.txt" 2>/dev/null || echo "No misconfigurations")
\`\`\`

---
*Report generated automatically. Please verify all findings manually.*
EOF

log "[✓] Vulnerability scan completed for $DOMAIN"
log "Report saved: $DOMAIN_DIR/VULN_REPORT.md"

# Mostrar principais achados
echo ""
echo "========================================="
echo "SCAN RESULTS FOR $DOMAIN"
echo "========================================="
echo "Critical/High: $(cat "$NUCLEI_DIR/critical_high.txt" 2>/dev/null | head -5 | wc -l) findings"
echo "XSS: $(cat "$DOMAIN_DIR/dalfox_results.txt" 2>/dev/null | wc -l) potentials"
echo "Directories: $(cat "$DOMAIN_DIR/found_directories.txt" 2>/dev/null | wc -l) found"
echo "========================================="