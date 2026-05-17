# Scripts de Ethical Hacking e Bug Bounty

Este repositório contém uma suíte de scripts de automação projetados para simplificar tarefas contínuas de Bug Bounty, como enumeração de subdomínios, análise de endpoints, fuzzing de diretórios e escaneamento de vulnerabilidades. O fluxo de trabalho integra diversas ferramentas da stack ProjectDiscovery e outras, otimizando o processo de descoberta.

## Estrutura dos Scripts

- `setup.sh`: Script inicial para criar a estrutura de diretórios e copiar todos os scripts.
- `install_tools.sh`: Instala e configura todas as ferramentas necessárias, pacotes de sistema, templates do Nuclei e wordlists.
- `master.sh`: Script principal que gerencia e coordena a execução por domínios.
- `domain_recon.sh`: Executa o reconhecimento passivo/ativo de subdomínios, coleta IPs, verifica portas (HTTP Probe), e extrai endpoints e parâmetros interessantes.
- `vuln_scan.sh`: Pega os resultados do reconhecimento e realiza fuzzing de diretórios, scan de vulnerabilidades com Nuclei, XSS com Dalfox, e reporta falhas críticas.

---

## 1. Configuração Inicial

### Passo 1: Preparar o ambiente
Primeiro, em sua máquina, clone o repositório e execute o arquivo de configuração e instalação:

```bash
chmod +x setup.sh
./setup.sh
```

O `setup.sh` fará o seguinte:
1. Criará o diretório base para os seus alvos (por padrão `$HOME/bugbounty`).
2. Copiará os scripts para `$HOME/bugbounty/scripts`.
3. Executará o `install_tools.sh` para instalar dependências em Go, ferramentas no sistema, e wordlists (`SecLists` e resolvers).

### Passo 2: Estrutura Inicial de Pastas
Após rodar o setup, a estrutura base (antes de executar os escaneamentos) será montada no seu diretório `$HOME/bugbounty` e ficará assim:

```text
~/bugbounty/
├── scripts/
│   ├── setup.sh
│   ├── install_tools.sh
│   ├── master.sh
│   ├── domain_recon.sh
│   └── vuln_scan.sh
└── <nome_do_programa>/
    └── domains.txt
```

Para cada alvo/empresa de bug bounty, crie uma pasta equivalente a `<nome_do_programa>` contendo um arquivo `domains.txt`. O arquivo `domains.txt` deve conter os domínios raiz para escaneamento (ex: `example.com`), um por linha.

---

## 2. Utilização

Para iniciar todo o processo de reconhecimento e escaneamento de vulnerabilidades em um programa de bug bounty:

Navegue até a pasta base (`~/bugbounty`) e execute o script master:

```bash
cd ~/bugbounty
./scripts/master.sh
```

O script vai identificar seus programas, escanear todos os domínios presentes no arquivo `domains.txt` de cada um chamando sequencialmente os scripts de reconhecimento `domain_recon.sh` e `vuln_scan.sh`.

---

## 3. Estrutura Final (Pós-Scan)

Depois que os scripts concluírem a varredura e reconhecimento, a pasta do seu domínio irá conter diversos relatórios, logs e listas de URLs encontrados, garantindo documentação e rastreabilidade:

```text
~/bugbounty/
├── scripts/
└── <nome_do_programa>/
    ├── domains.txt
    └── example.com/
        ├── alive.txt (Subdomínios ativos)
        ├── dnsx_output.txt
        ├── RECON_SUMMARY.txt (Resumo de métricas do Recon)
        ├── VULN_REPORT.md (Relatório executivo final de Vulnerabilidades)
        ├── dalfox_results.txt (Resultados de possíveis XSS)
        ├── found_directories.txt (Diretórios encontrados via ffuf)
        ├── httpx_output.txt 
        ├── interesting_endpoints.txt
        ├── ips.txt (IPs únicos de resolução)
        ├── js_files.txt (Arquivos JavaScript encontrados)
        ├── katana_urls.txt
        ├── parameters.txt (Parâmetros de URL isolados)
        ├── subs.txt (Todos os subdomínios descobertos)
        ├── technologies.txt (Tecnologias web detectadas)
        ├── urls.txt (Todas as URLs combinadas)
        ├── urls_with_params.txt
        ├── logs/
        │   ├── recon.log
        │   └── scan.log
        └── scans/
            ├── ffuf/
            │   └── example.com.json (Dump de resultados brutos do ffuf)
            └── nuclei/
                ├── critical_high.txt (Vulnerabilidades Críticas/Altas)
                ├── exposures.txt
                ├── medium_low.txt
                └── misconfigs.txt
```

---

## 4. Configuração do Notify (Alertas no Discord)

Os scripts estão preparados para usar o `notify` (da ProjectDiscovery) para enviar mensagens em tempo real quando uma vulnerabilidade crítica for detectada. O script faz isso mandando o alerta no canal `vulns` (`notify -id vulns`).

Para receber essas notificações diretamente no seu **Discord**, siga o tutorial:

1. **Crie o Webhook no Discord:**
   Abra o seu servidor no Discord, vá em: **Configurações do Servidor > Integrações > Webhooks > Novo Webhook**.
   Dê um nome, escolha o canal onde deseja receber as notificações e clique em "Copiar a URL do Webhook".

2. **Crie a pasta de configuração:**
   No seu terminal Linux/macOS, garanta que a pasta do notify existe:
   ```bash
   mkdir -p ~/.config/notify
   ```

3. **Crie o arquivo de Provider:**
   O `notify` procura configurações no arquivo `~/.config/notify/provider-config.yaml`.
   Crie ou edite este arquivo, adicionando o código abaixo. Substitua a URL por aquela que você copiou no passo 1.

   ```yaml
   discord:
     - id: "vulns"
       discord_webhook_url: "https://discord.com/api/webhooks/XXXXXXXX/XXXXXXXX"
   ```

4. **Pronto!** Na próxima vez que o Nuclei encontrar algo "Crítico" ou "Alto", o `vuln_scan.sh` enviará a falha para o seu Discord em tempo real.

---

## Disclaimer

Uso exclusivo para ambientes autorizados e programas públicos/privados de Bug Bounty que obedeçam a regras de teste ético. O autor não se responsabiliza pelo mau uso das ferramentas aqui utilizadas.
