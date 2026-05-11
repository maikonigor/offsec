#!/bin/bash

# Função para mostrar a ajuda
show_help() {
  echo "Uso: subdomain-scan -url <domínio> [-dir <diretório>] [-v] [-h]"
  echo
  echo "  -url <domínio>     O domínio a ser escaneado (obrigatório)"
  echo "  -dir <diretório>   O diretório onde os resultados serão salvos (opcional)"
  echo "  -v                 Ativa o modo verbose (mostra o progresso)"
  echo "  -h                 Exibe esta ajuda"
}

# Função principal para o scan
subdomain_scan() {
  local domain=$1
  local dir=$2
  local verbose=$3

  # Verifica se o gau está instalado
  if ! command -v gau &> /dev/null; then
    echo "Erro: o programa 'gau' (GetAllUrls) não está instalado ou não está no PATH."
    echo "Instale o gau: https://github.com/lc/gau"
    exit 1
  fi

  # Comando base para execução do Amass
  local amass_command="amass enum -d $domain"

  if [[ "$verbose" == "true" ]]; then
    echo "Executando amass para o domínio $domain..."
  fi

  if [[ -n "$dir" ]]; then
    amass_command="$amass_command -dir $dir"
  fi

  # Execução do Amass
  if [[ "$verbose" == "true" ]]; then
    $amass_command | grep -oP '([a-zA-Z0-9-]+\.)+fabianovasconcelos\.com' | sed 's/^92m//g' | tee subdomains.txt
  else
    $amass_command | grep -oP '([a-zA-Z0-9-]+\.)+fabianovasconcelos\.com' | sed 's/^92m//g' > subdomains.txt
  fi

  echo "$domain" >> subdomains.txt

  # Rodar o gau para mapear URLs
  if [[ "$verbose" == "true" ]]; then
    echo "Executando gau para coletar URLs dos subdomínios..."
    cat subdomains.txt | gau | tee urls.txt
  else
    cat subdomains.txt | gau > urls.txt
  fi

  # Se tiver diretório, mover os arquivos
  if [[ -n "$dir" ]]; then
    if [[ ! -d "$dir" ]]; then
      echo "O diretório $dir não existe. Criando..."
      mkdir -p "$dir"
    fi
    mv subdomains.txt urls.txt "$dir/"
    echo "Resultados salvos em $dir/subdomains.txt e $dir/urls.txt"
  else
    echo "Resultados salvos em subdomains.txt e urls.txt"
  fi
}

# Processando os parâmetros de entrada
while [[ "$1" != "" ]]; do
  case $1 in
    -h)
      show_help
      exit 0
      ;;
    -v)
      verbose=true
      shift
      ;;
    -url)
      url=$2
      shift 2
      ;;
    -dir)
      dir=$2
      shift 2
      ;;
    *)
      echo "Parâmetro desconhecido: $1. Use -h para ajuda."
      exit 1
      ;;
  esac
done

if [[ -z "$url" ]]; then
  echo "Erro: O parâmetro -url é obrigatório."
  show_help
  exit 1
fi

# Executa o scan
subdomain_scan "$url" "$dir" "$verbose"
