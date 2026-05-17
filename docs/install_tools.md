# install_tools.sh

O `install_tools.sh` é um script completo de provisionamento de dependências. Ele assegura que todas as ferramentas de terceiros utilizadas pelo pipeline de Bug Bounty estejam corretamente instaladas, no `$PATH`, e configuradas.

## O que ele faz?

1. **Verificação do Go (Golang)**:
   A maior parte das ferramentas modernas de recon é escrita em Go. O script verifica se o Go está instalado e se o `$GOPATH/bin` está presente no seu PATH.

2. **Instalação de Ferramentas via Go (`go install`)**:
   Instala as versões mais recentes das ferramentas utilitárias:
   - ProjectDiscovery: `subfinder`, `httpx`, `dnsx`, `naabu`, `katana`, `uncover`, `notify`, `shuffledns`, `nuclei`
   - Tomnomnom: `unfurl`, `gf`, `anew`, `assetfinder`, `waybackurls`
   - Outros: `gau`, `ffuf`

3. **Instalação de Ferramentas de Sistema**:
   Caso o sistema seja baseado em Debian/Ubuntu, utiliza o `apt` para instalar ferramentas primárias como `massdns`, `whois`, `parallel` e `jq`. Instala também o `arjun` via `pip3` e ferramentas como `amass` e `dalfox` via `snap`.

4. **Configuração de Templates GF**:
   O `gf` é uma ferramenta que analisa saídas através de arquivos `.json` com padrões Regex pré-definidos (para sqli, xss, ssrf, etc). O script clona os padrões oficiais e também o repositório popular `Gf-Patterns`.

5. **Configuração de Wordlists (SecLists & Resolvers)**:
   Verifica se o repositório do `SecLists` e a wordlist de resolvers do `Trickest` existem em `/usr/share/wordlists`. Se não, ele se oferece para clonar/baixar automaticamente, exigindo privilégios `sudo`.

6. **Atualização do Nuclei**:
   Ao final, ele roda `nuclei -update-templates` para baixar as assinaturas de vulnerabilidades mais recentes.

## Como usar

Normalmente invocado pelo `setup.sh`. Caso queira reinstalar ou atualizar as ferramentas isoladamente:
```bash
./install_tools.sh
```
