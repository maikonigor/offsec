#!/bin/bash

# Script de instalação de ferramentas de bug bounty e segurança
# Autor: Automatizado
# Data: $(date +%Y-%m-%d)

set -e  # Sai do script se algum comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens
print_message() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# Verificar se Go está instalado
check_go() {
    print_info "Verificando instalação do Go..."
    if ! command -v go &> /dev/null; then
        print_error "Go não está instalado. Por favor, instale Go primeiro."
        print_info "Visite: https://golang.org/dl/"
        exit 1
    fi
    print_message "Go encontrado: $(go version)"
}

# Verificar se o diretório bin do Go está no PATH
check_go_path() {
    if [[ ":$PATH:" != *":$(go env GOPATH)/bin:"* ]]; then
        print_warning "Diretório $(go env GOPATH)/bin não está no seu PATH"
        print_info "Adicione estas linhas ao seu ~/.bashrc ou ~/.zshrc:"
        echo 'export PATH=$PATH:$(go env GOPATH)/bin'
        echo ""
        read -p "Deseja adicionar agora? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "export PATH=\$PATH:$(go env GOPATH)/bin" >> ~/.bashrc
            echo "export PATH=\$PATH:$(go env GOPATH)/bin" >> ~/.zshrc 2>/dev/null || true
            export PATH=$PATH:$(go env GOPATH)/bin
            print_message "PATH atualizado. Recarregue seu shell ou execute: source ~/.bashrc"
        else
            print_warning "Lembre-se de adicionar $(go env GOPATH)/bin ao seu PATH manualmente"
        fi
    fi
}

# Instalar ferramentas via go install
install_go_tools() {
    print_message "Instalando ferramentas Go..."
    
    tools=(
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
        "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        "github.com/projectdiscovery/katana/cmd/katana@latest"
        "github.com/projectdiscovery/uncover/cmd/uncover@latest"
        "github.com/projectdiscovery/notify/cmd/notify@latest"
        "github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
        "github.com/lc/gau/v2/cmd/gau@latest"
        "github.com/tomnomnom/unfurl@latest"
        "github.com/tomnomnom/gf@latest"
        "github.com/tomnomnom/anew@latest"
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        "github.com/tomnomnom/assetfinder@latest"
        "github.com/tomnomnom/waybackurls@latest"
        "github.com/ffuf/ffuf/v2@latest"
    )
    
    for tool in "${tools[@]}"; do
        print_info "Instalando: $tool"
        if go install -v "$tool"; then
            print_message "✓ $tool instalado com sucesso"
        else
            print_error "✗ Falha ao instalar $tool"
        fi
        echo ""
    done
}

# Instalar ferramentas de sistema
install_system_tools() {
    print_message "Instalando ferramentas de sistema..."
    
    # Verificar se é Debian/Ubuntu
    if command -v apt &> /dev/null; then
        print_info "Sistema baseado em Debian/Ubuntu detectado"
        
        # Atualizar pacotes
        sudo apt update
        
        # Instalar massdns e dependências a partir do código fonte
        print_info "Instalando massdns..."
        sudo apt install -y build-essential git
        if ! command -v massdns &> /dev/null; then
            cd /tmp
            git clone https://github.com/blechschmidt/massdns.git
            cd massdns
            make
            sudo cp bin/massdns /usr/local/bin/
            cd - > /dev/null
            rm -rf /tmp/massdns
        else
            print_info "massdns já está instalado."
        fi
        
        # Instalar whois
        print_info "Instalando whois..."
        sudo apt install -y whois
        
        # Instalar arjun via pip (pois não está no apt)
        print_info "Instalando arjun..."
        if command -v pip3 &> /dev/null; then
            pip3 install arjun
        else
            print_warning "pip3 não encontrado. Instalando python3-pip..."
            sudo apt install -y python3-pip
            pip3 install arjun
        fi

        print_info "instalando parallel"
        sudo apt install -y parallel
        
        print_info "Instalando jq..."
        sudo apt install -y jq
        
        print_message "Ferramentas de sistema instaladas"
    else
        print_warning "Sistema não baseado em Debian/Ubuntu. Instale manualmente:"
        print_info "- massdns"
        print_info "- whois"
        print_info "- arjun (via pip)"
        print_info "- jq"
    fi
    
    # Instalar snap packages
    print_info "Instalando pacotes Snap..."
    
    # Verificar se snap está instalado
    if ! command -v snap &> /dev/null; then
        print_warning "Snap não está instalado. Instale snap primeiro ou use métodos alternativos"
        print_info "Para instalar amass manualmente: go install -v github.com/OWASP/Amass/v3/...@master"
        print_info "Para instalar dalfox manualmente: go install github.com/hahwul/dalfox/v2@latest"
    else
        print_info "Instalando amass via snap..."
        sudo snap install amass || print_warning "Falha ao instalar amass via snap"
        
        print_info "Instalando dalfox via snap..."
        sudo snap install dalfox || print_warning "Falha ao instalar dalfox via snap"
    fi
}

# Configurar templates do GF
setup_gf_templates() {
    print_message "Configurando templates do GF..."
    
    # Verificar se gf foi instalado
    if ! command -v gf &> /dev/null; then
        print_error "GF não encontrado. Instale o GF primeiro."
        return 1
    fi
    
    # Criar diretório .gf se não existir
    mkdir -p ~/.gf
    
    # Clonar e instalar padrões do GF
    print_info "Baixando padrões do GF..."
    if [ -d "/tmp/Gf-Patterns" ]; then
        rm -rf /tmp/Gf-Patterns
    fi
    
    git clone https://github.com/1ndianl33t/Gf-Patterns /tmp/Gf-Patterns
    
    # Copiar padrões
    print_info "Copiando padrões para ~/.gf/"
    if cp /tmp/Gf-Patterns/*.json ~/.gf/ 2>/dev/null; then
        print_message "Padrões do GF instalados com sucesso"
    else
        print_warning "Nenhum padrão JSON encontrado para copiar"
    fi
    
    # Baixar padrões adicionais do repositório oficial do GF
    print_info "Baixando padrões adicionais do repositório oficial..."
    if [ ! -d "/tmp/Gf-Patterns-Official" ]; then
        git clone https://github.com/tomnomnom/gf /tmp/Gf-Patterns-Official
        cp /tmp/Gf-Patterns-Official/examples/*.json ~/.gf/ 2>/dev/null || true
    fi
    
    # Limpar
    rm -rf /tmp/Gf-Patterns /tmp/Gf-Patterns-Official
    
    print_message "Configuração do GF concluída"
    print_info "Para usar: gf list (ver padrões disponíveis)"
}

# Verificar instalações
verify_installations() {
    print_message "Verificando instalações..."
    echo ""
    
    tools=(
        "subfinder"
        "httpx"
        "dnsx"
        "naabu"
        "katana"
        "uncover"
        "notify"
        "shuffledns"
        "gau"
        "unfurl"
        "gf"
        "anew"
        "nuclei"
        "assetfinder"
        "waybackurls"
        "ffuf"
        "amass"
        "massdns"
        "whois"
        "arjun"
        "dalfox"
        "jq"
    )
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_message "✓ $tool - OK"
        else
            print_error "✗ $tool - Não encontrado"
        fi
    done
}

# Configurar wordlists e resolvers
setup_wordlists() {
    print_message "Verificando wordlists e resolvers..."
    
    # SecLists
    if [ ! -d "/usr/share/wordlists/SecLists" ]; then
        print_warning "SecLists não encontrado em /usr/share/wordlists/SecLists"
        read -p "Deseja instalar o SecLists? Isso pode demorar e requer sudo. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Clonando SecLists..."
            sudo mkdir -p /usr/share/wordlists
            sudo git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists
            print_message "SecLists instalado com sucesso"
        else
            print_warning "SecLists não instalado. Algumas funções podem falhar."
        fi
    else
        print_message "✓ SecLists encontrado"
    fi

    # Resolvers
    if [ ! -f "/usr/share/wordlists/resolvers/resolvers.txt" ]; then
        print_warning "Arquivo de resolvers não encontrado em /usr/share/wordlists/resolvers/resolvers.txt"
        read -p "Deseja baixar os resolvers do Trickest? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Baixando resolvers..."
            sudo mkdir -p /usr/share/wordlists/resolvers
            sudo wget -qO /usr/share/wordlists/resolvers/resolvers.txt https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt
            print_message "Resolvers instalados com sucesso"
        else
            print_warning "Resolvers não instalados. Algumas funções podem falhar."
        fi
    else
        print_message "✓ Resolvers encontrados"
    fi
}

# Atualizar nuclei templates
update_nuclei_templates() {
    print_message "Atualizando templates do Nuclei..."
    if command -v nuclei &> /dev/null; then
        nuclei -update-templates
        print_message "Templates do Nuclei atualizados"
    else
        print_warning "Nuclei não encontrado. Pule atualização de templates"
    fi
}

# Função principal
main() {
    print_message "Iniciando instalação das ferramentas de segurança"
    print_info "Data: $(date)"
    echo ""
    
    # Verificar requisitos
    check_go
    check_go_path
    
    # Instalar ferramentas
    install_go_tools
    install_system_tools
    setup_gf_templates
    setup_wordlists
    update_nuclei_templates
    
    # Verificar instalações
    verify_installations
    
    print_message "Instalação concluída!"
    print_info "Não se esqueça de adicionar ~/go/bin ao seu PATH se ainda não fez"
    echo ""
    print_info "Comandos úteis:"
    echo "  gf list                    # Listar padrões do GF"
    echo "  nuclei -version            # Verificar versão do Nuclei"
    echo "  subfinder -version         # Verificar Subfinder"
}

# Executar função principal
main
