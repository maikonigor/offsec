# vuln_scan.sh

O `vuln_scan.sh` assume assim que o `domain_recon.sh` termina. Ele pega todos os assets provados como ativos e os parâmetros descobertos e os bombardeia em busca de fragilidades e "Low Hanging Fruits" (frutas baixas/fáceis).

## Fases de Escaneamento

### 1. Escaneamento com Nuclei
A principal bateria de detecção. Lê o arquivo `alive.txt` e roda o `nuclei` em categorias diferentes.
- **Critical & High**: Vazamento de tokens, RCEs, injeções perigosas. Salvos em `critical_high.txt`.
- **Medium & Low**: Salvos em `medium_low.txt`.
- **Misconfigurations e Exposures**: Permissões erradas de servidor, arquivos de banco de dados, open redirects, expostos intencionalmente ou por erro.

### 2. Escaneamento de XSS (Cross-Site Scripting)
O script sabe que parâmetros na URL (como `?busca=...`) são os vetores mais comuns de Reflexive XSS.
- Pega as top 100 URLs contendo parâmetros que vieram da fase de recon.
- Roda o **Dalfox** focando apenas em PoCs comprovadas e rápidas (`--only-poc`). Salva os indícios em `dalfox_results.txt`.

### 3. Fuzzing de Diretórios
Para os top 5 domínios/URLs identificadas em `alive.txt`, o script tenta encontrar arquivos ocultos que não foram pegos pelo web crawler ou pelo histórico (por exemplo, `/admin`, `/.git`, `/api/v2/`).
- Roda o **ffuf** enviando centenas de requisições baseadas no dicionário comum `common.txt` do Kali/Dirb. 
- Extrai os arquivos encontrados com status HTTP 200 usando `jq` e os documenta em `found_directories.txt`.

### 4. Notificações e Reporte
Se durante a Fase 1 o Nuclei encontrar vulnerabilidades marcadas como Critical ou High, ele disparará o provider do **Notify**, enviando silenciosamente e imediatamente a evidência para sua Webhook configurada (Ex: Discord ou Slack).
Por fim, cria um belo relatório final consolidado (`VULN_REPORT.md`) com contagens limpas, para rápida leitura visual.

## Como usar
Uso individual (geralmente orquestrado pelo `master.sh`):
```bash
./vuln_scan.sh example.com /caminho/do/alvo
```
