# domain_recon.sh

O `domain_recon.sh` é responsável por todo o mapeamento do perímetro do alvo. Seu objetivo não é testar vulnerabilidades, mas descobrir o máximo possível de superfície exposta.

## Fluxo e Fases de Execução

### Fase 1: Enumeração Passiva de Subdomínios
Busca subdomínios em fontes abertas da internet (OSINT) sem interagir diretamente com os servidores alvo.
- Utiliza o `subfinder`, `assetfinder` e o `amass` no modo passivo.
- Os resultados vão para `subs.txt` utilizando o utilitário `anew` para que os dados sejam sempre complementados sem duplicação.

### Fase 2: Validação de Subdomínios
Pega todos os subdomínios e checa quais realmente possuem registro DNS válido (subdomínios que existem ativamente na rede).
- Utiliza o `dnsx`. Extrai simultaneamente os endereços IPs para o arquivo `ips.txt`.

### Fase 3: DNS Bruteforce (Opcional)
Se ativado via parâmetro, ele não dependerá apenas da coleta passiva; ele chutará ativamente milhares de subdomínios prováveis.
- Utiliza o `shuffledns` passando a wordlist top-5000 do `SecLists` e validando com os resolvers baixados no setup. Adiciona os sucessos em `subs.txt`.

### Fase 4: HTTP Probing
Agora ele precisa saber quais dos domínios vivos estão servindo HTTP/HTTPS ativamente em portas conhecidas.
- Utiliza o `httpx`. Gera o arquivo base mais importante do processo: `alive.txt`, contendo apenas as URLs funcionais. Ele também rastreia as tecnologias sendo usadas e salva em `technologies.txt`.

### Fase 5: Coleta de URLs (URL Collection)
Navega pelos domínios vivos buscando por históricos de URLs, APIs e páginas indexadas.
- Utiliza serviços de histórico passivo (`gau` e `waybackurls`) e navegação ativa (crawling) profunda com `katana`. Salva tudo no arquivo mestre `urls.txt`.

### Fase 6: Extração de Parâmetros e Endpoints
O script filtra inteligentemente `urls.txt` para fins práticos.
- Usa o `unfurl` para pegar apenas os parâmetros que estão na URL (ex: `?id=1`) e os joga em `parameters.txt`.
- Filtra arquivos com extensão interessante (`.php`, `.json`, `.sql`, etc) em `interesting_endpoints.txt`.
- Salva arquivos Javascript em `js_files.txt`.

Ao final, ele imprime um sumário (`RECON_SUMMARY.txt`) com a contagem exata do que foi encontrado.

## Como usar
Uso individual (geralmente orquestrado pelo `master.sh`):
```bash
./domain_recon.sh example.com /caminho/do/alvo true
```
*(Onde `true` ativa a Fase 3 - DNS Bruteforce)*
