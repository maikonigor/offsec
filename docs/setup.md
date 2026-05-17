# setup.sh

O `setup.sh` é o ponto de partida do seu fluxo de trabalho de Bug Bounty. Ele tem a responsabilidade de preparar o ambiente onde seus testes serão conduzidos.

## O que ele faz?

1. **Configuração de Diretório Base**: 
   Por padrão, o script define um diretório `$HOME/bugbounty` como o espaço de trabalho principal (`BUG_BOUNTY_DIR`). Todos os programas alvo e logs residirão aqui.

2. **Organização de Scripts**:
   Ele cria uma pasta `scripts/` dentro de `$HOME/bugbounty` e copia todos os scripts `.sh` deste repositório para lá. Isso garante que você tenha um local centralizado de execução isolado do seu repositório Git. Em seguida, aplica permissão de execução (`chmod +x`) a todos eles.

3. **Geração de Exemplo**:
   Para demonstrar o padrão de estrutura, ele cria uma pasta chamada `example-target` e coloca um arquivo base `domains.txt` lá dentro com exemplos comentados.

4. **Instalação das Dependências**:
   Após estruturar tudo, o `setup.sh` chama o `install_tools.sh` automaticamente para garantir que todas as ferramentas que o pipeline precisa estejam instaladas e prontas.

## Como usar

No repositório recém clonado:
```bash
chmod +x setup.sh
./setup.sh
```
