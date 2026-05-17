#!/bin/bash
# master.sh - Script principal que gerencia todos os alvos

export PATH=$PATH:$HOME/go/bin
BUG_BOUNTY_DIR="$HOME/bugbounty"
LOG_FILE="$BUG_BOUNTY_DIR/master.log"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Flags
ENABLE_BRUTE=false
ENABLE_VULN_SCAN=true
SPECIFIC_TARGET=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --brute) ENABLE_BRUTE=true ;;
        --no-vuln) ENABLE_VULN_SCAN=false ;;
        --target) SPECIFIC_TARGET="$2"; shift ;;
        --help) 
            echo "Usage: $0 [OPTIONS]"
            echo "  --brute      Enable DNS bruteforce"
            echo "  --no-vuln    Skip vulnerability scanning"
            echo "  --target     Process specific target only"
            exit 0
            ;;
    esac
    shift
done

# Função para processar um único alvo
process_target() {
    local TARGET_DIR="$1"
    local TARGET_NAME=$(basename "$TARGET_DIR")
    local DOMAINS_FILE="$TARGET_DIR/domains.txt"
    
    if [ ! -f "$DOMAINS_FILE" ]; then
        log "${YELLOW}[!] No domains.txt found in $TARGET_DIR${NC}"
        return 1
    fi
    
    log "${GREEN}[+] Processing target: $TARGET_NAME${NC}"
    
    # Ler cada domínio do arquivo
    while IFS= read -r DOMAIN || [ -n "$DOMAIN" ]; do
        # Skip empty lines and comments
        [[ -z "$DOMAIN" || "$DOMAIN" =~ ^#.*$ ]] && continue
        
        log "${BLUE}[→] Starting recon for: $DOMAIN${NC}"
        
        # Criar pasta para o domínio
        DOMAIN_DIR="$TARGET_DIR/$DOMAIN"
        mkdir -p "$DOMAIN_DIR"/{logs,recon,scans,temp}
        
        # Executar script de recon para este domínio
        ./$BUG_BOUNTY_DIR/scripts/domain_recon.sh "$DOMAIN" "$DOMAIN_DIR" "$ENABLE_BRUTE"
        
        # Executar scan de vulnerabilidades se habilitado
        if [ "$ENABLE_VULN_SCAN" = true ]; then
            ./$BUG_BOUNTY_DIR/scripts/vuln_scan.sh "$DOMAIN" "$DOMAIN_DIR"
        fi
        
        log "${GREEN}[✓] Completed: $DOMAIN${NC}"
        echo "---"
        
    done < "$DOMAINS_FILE"
}

log "${GREEN}[+] Starting Bug Bounty Automation${NC}"
log "Date: $(date)"
log "Brute force: $ENABLE_BRUTE"
log "Vuln scan: $ENABLE_VULN_SCAN"

# Processar alvos
if [ -n "$SPECIFIC_TARGET" ]; then
    # Processar apenas um alvo específico
    TARGET_PATH="$BUG_BOUNTY_DIR/$SPECIFIC_TARGET"
    if [ -d "$TARGET_PATH" ]; then
        process_target "$TARGET_PATH"
    else
        log "${RED}[!] Target not found: $SPECIFIC_TARGET${NC}"
        exit 1
    fi
else
    # Processar todos os alvos
    find "$BUG_BOUNTY_DIR" -maxdepth 1 -type d | while read -r TARGET_DIR; do
        # Skip the base directory and scripts folder
        if [[ "$TARGET_DIR" == "$BUG_BOUNTY_DIR" || "$TARGET_DIR" == "$BUG_BOUNTY_DIR/scripts" ]]; then
            continue
        fi
        process_target "$TARGET_DIR"
    done
fi

log "${GREEN}[✅] All targets processed!${NC}"