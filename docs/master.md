# master.sh

O `master.sh` é o maestro da orquestração do seu fluxo de Bug Bounty. Em vez de rodar o reconhecimento e os escaneamentos manualmente domínio por domínio, você chama este script.

*(Nota: o funcionamento base detalhado depende da sua implementação interna de master.sh, mas segue a estrutura lógica da arquitetura do repositório).*

## O que ele faz?

1. **Leitura da Estrutura de Alvos**:
   Ele navega por todas as subpastas dentro do seu diretório base (por exemplo `$HOME/bugbounty/`), procurando pelos arquivos `domains.txt` de cada programa.

2. **Execução Coordenada**:
   Para cada domínio lido em `domains.txt`, ele:
   - Aciona o `domain_recon.sh`, passando o domínio alvo, o diretório onde os dados serão salvos, e uma flag informando se deve ou não fazer brute force DNS.
   - Assim que o reconhecimento termina, ele aciona o `vuln_scan.sh`, passando as mesmas informações básicas para que ele leia os arquivos de saída do recon e inicie o ataque direcionado.

3. **Gestão do Fluxo e Paralelismo**:
   Dependendo da implementação, ele pode orquestrar o processo em paralelo para lidar com múltiplos programas rapidamente usando o `GNU parallel`.

## Como usar

Normalmente você não passa parâmetros, ele deduz da estrutura do diretório:
```bash
cd ~/bugbounty
./scripts/master.sh
```
