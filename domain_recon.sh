#!/bin/bash
# recon.sh - Script de reconhecimento para um domínio

# Usage: ./recon.sh <domain> <domain_dir> <enable_brute>

DOMAIN="$1"
DOMAIN_DIR="$2"
ENABLE_BRUTE="$3"

LOG_FILE="$DOMAIN_DIR/logs/recon.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Arquivos de saída
SUBS_FILE="$DOMAIN_DIR/subs.txt"
ALIVE_FILE="$DOMAIN_DIR/alive.txt"
URLS_FILE="$DOMAIN_DIR/urls.txt"
IPS_FILE="$DOMAIN_DIR/ips.txt"
TECH_FILE="$DOMAIN_DIR/technologies.txt"
BRUTE_FILE="$DOMAIN_DIR/brute_dns.txt"

log "=== Starting Recon for $DOMAIN ==="

# FASE 1: Subdomain Enumeration Passiva
log "[1/6] Passive subdomain enumeration..."

# Subfinder
log "[*] Running subfinder..."
subfinder -d "$DOMAIN" -silent | anew "$SUBS_FILE"

# Assetfinder
if command -v assetfinder &> /dev/null; then
    log "[*] Running assetfinder..."
    assetfinder --subs-only "$DOMAIN" | anew "$SUBS_FILE"
fi

# Amass (rápido, modo passivo)
if command -v amass &> /dev/null; then
    log "[*] Running amass (passive)..."
    amass enum -passive -d "$DOMAIN" -silent | anew "$SUBS_FILE"
fi

# FASE 2: Validação de Subdomínios
log "[2/6] Validating subdomains with dnsx..."

cat "$SUBS_FILE" | dnsx -silent -a -resp | tee "$DOMAIN_DIR/dnsx_output.txt"
cat "$DOMAIN_DIR/dnsx_output.txt" | cut -d' ' -f1 | sort -u > "$SUBS_FILE.tmp"
mv "$SUBS_FILE.tmp" "$SUBS_FILE"

SUBS_COUNT=$(wc -l < "$SUBS_FILE")
log "[✓] Found $SUBS_COUNT active subdomains"

# Extrair IPs
cat "$DOMAIN_DIR/dnsx_output.txt" | awk '{print $2}' | grep -v '\[\]' | sort -u > "$IPS_FILE"
log "[✓] Extracted $(wc -l < $IPS_FILE) unique IPs"

# FASE 3: DNS Bruteforce (opcional)
if [ "$ENABLE_BRUTE" = "true" ]; then
    log "[3/6] DNS bruteforce with shuffledns..."
    
    if command -v shuffledns &> /dev/null; then
        shuffledns -d "$DOMAIN" \
            -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt \
            -r /usr/share/wordlists/resolvers/resolvers.txt \
            -o "$BRUTE_FILE" \
            -t 100 \
            -mode bruteforce \
            -silent 2>/dev/null
        
        if [ -f "$BRUTE_FILE" ]; then
            # Validar resultados do bruteforce
            cat "$BRUTE_FILE" | dnsx -silent | anew "$SUBS_FILE"
            log "[✓] Added $(wc -l < $BRUTE_FILE) from bruteforce"
        fi
    else
        log "[!] shuffledns not found, skipping bruteforce"
    fi
fi

# FASE 4: HTTP Probing
log "[4/6] HTTP probing with httpx..."

cat "$SUBS_FILE" | httpx \
    -silent \
    -status-code \
    -title \
    -tech-detect \
    -content-length \
    -web-server \
    -follow-redirects \
    -threads 100 \
    -o "$DOMAIN_DIR/httpx_output.txt"

# Extrair URLs vivas
cat "$DOMAIN_DIR/httpx_output.txt" | cut -d' ' -f1 > "$ALIVE_FILE"
ALIVE_COUNT=$(wc -l < "$ALIVE_FILE")
log "[✓] Found $ALIVE_COUNT live URLs"

# Extrair tecnologias
cat "$DOMAIN_DIR/httpx_output.txt" | grep -oP '\[.*?\]' | sort -u > "$TECH_FILE"

# FASE 5: URL Collection
log "[5/6] Collecting URLs..."

# Gau
if command -v gau &> /dev/null; then
    log "[*] Running gau..."
    gau --subs "$DOMAIN" | anew "$URLS_FILE"
fi

# Katana
if command -v katana &> /dev/null; then
    log "[*] Running katana..."
    katana -list "$ALIVE_FILE" -silent -d 3 -o "$DOMAIN_DIR/katana_urls.txt"
    cat "$DOMAIN_DIR/katana_urls.txt" | anew "$URLS_FILE"
fi

# Waybackurls (alternativa)
if command -v waybackurls &> /dev/null; then
    log "[*] Running waybackurls..."
    echo "$DOMAIN" | waybackurls | anew "$URLS_FILE"
fi

URLS_COUNT=$(wc -l < "$URLS_FILE")
log "[✓] Collected $URLS_COUNT unique URLs"

# FASE 6: Extração de Parâmetros
log "[6/6] Extracting parameters..."

# Extrair parâmetros únicos
cat "$URLS_FILE" | grep -E '\?.*=' | unfurl keys | sort -u > "$DOMAIN_DIR/parameters.txt"

# Extrair endpoints interessantes
cat "$URLS_FILE" | \
    grep -E '\.(php|asp|aspx|jsp|do|action|html|htm|json|xml|txt|pdf|zip|tar|gz|rar|sql|bak|old|swp)' \
    > "$DOMAIN_DIR/interesting_endpoints.txt"

# Extrair arquivos JS para análise posterior
cat "$URLS_FILE" | grep -E '\.js$' > "$DOMAIN_DIR/js_files.txt"

# Criar resumo
cat > "$DOMAIN_DIR/RECON_SUMMARY.txt" << EOF
===========================================
Recon Summary for $DOMAIN
===========================================
Date: $(date)
Active Subdomains: $SUBS_COUNT
Live URLs: $ALIVE_COUNT
Total URLs Collected: $URLS_COUNT
Unique IPs: $(wc -l < $IPS_FILE)
Parameters Found: $(wc -l < $DOMAIN_DIR/parameters.txt)
JS Files: $(wc -l < $DOMAIN_DIR/js_files.txt)

Technologies Detected:
$(cat "$TECH_FILE" 2>/dev/null || echo "None detected")
===========================================
EOF

log "[✓] Recon completed for $DOMAIN"
log "Results saved in: $DOMAIN_DIR"

# Mostrar resumo
cat "$DOMAIN_DIR/RECON_SUMMARY.txt"