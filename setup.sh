#!/bin/bash
# setup.sh - Configuração inicial do ambiente

export PATH=$PATH:$HOME/go/bin
BUG_BOUNTY_DIR="$HOME/bugbounty"

echo "[+] Setting up Bug Bounty directory structure..."

# Criar diretório principal e de scripts
mkdir -p "$BUG_BOUNTY_DIR/scripts"

# Copiar scripts para o diretório de scripts
cp *.sh "$BUG_BOUNTY_DIR/scripts/"
chmod +x "$BUG_BOUNTY_DIR/scripts/"*.sh

# Criar arquivo de exemplo de alvo
mkdir -p "$BUG_BOUNTY_DIR/example-target"
cat > "$BUG_BOUNTY_DIR/example-target/domains.txt" << 'EOF'
# List your domains here (one per line)
# example.com
# test.com
# subdomain.example.com
EOF

echo "[+] Directory structure created!"
echo ""
echo "Next steps:"
echo "1. Create your targets: mkdir -p $BUG_BOUNTY_DIR/<target_name>"
echo "2. Add domains to: $BUG_BOUNTY_DIR/<target_name>/domains.txt"
echo "3. Run master script: cd $BUG_BOUNTY_DIR && ./scripts/master.sh"
echo ""
echo "Example structure:"
echo "bugbounty/"
echo "├── hackerone/"
echo "│   ├── domains.txt"
echo "│   ├── example.com/"
echo "│   │   ├── subs.txt"
echo "│   │   ├── urls.txt"
echo "│   │   └── nuclei_out.txt"
echo "│   └── test.com/"
echo "└── bugcrowd/"
echo "    ├── domains.txt"
echo "    └── target.com/"

echo "[+] Instaling tools..."
./scripts/install_tools.sh

echo "[+] Setup completed!"