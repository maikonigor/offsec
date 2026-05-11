#!/bin/bash

# Função para exibir ajuda
show_help() {
  echo "======================================="
  echo "         URL Scan com GF Patterns"
  echo "======================================="
  echo
  echo "Uso:"
  echo "  ./url-scan.sh -url <url> [-v]"
  echo "  ./url-scan.sh -f <arquivo> [-v]"
  echo
  echo "Parâmetros:"
  echo "  -url <url>        Escaneia uma única URL"
  echo "  -f <arquivo>      Escaneia uma lista de URLs de um arquivo"
  echo "  -v                Modo verbose (exibe o andamento)"
  echo "  -h                Mostra esta ajuda"
  echo
  echo "Saída:"
  echo "  Para cada padrão encontrado em ~/.gf/*.json, será criado um"
  echo "  arquivo com as URLs encontradas dentro do diretório:"
  echo "    ./url-candidates/<pattern>.txt"
  echo
  echo "Pré-requisitos:"
  echo "  - O utilitário 'gf' deve estar instalado e acessível no PATH"
  echo "  - Os patterns JSON devem estar no diretório ~/.gf/"
  echo
  exit 0
}

# Verifica se 'gf' está instalado
if ! command -v gf &> /dev/null; then
  echo "Erro: o utilitário 'gf' não está instalado ou não está no PATH."
  echo "Você pode instalá-lo em: https://github.com/tomnomnom/gf"
  exit 1
fi

# Inicialização de variáveis
verbose=false
url_input=""
file_input=""
output_dir=""

# Cores
GREEN="\033[0;32m"    # Verde
RESET="\033[0m"       # Resetar cor

# Processamento de argumentos
while [[ "$1" != "" ]]; do
  case $1 in
    -url)
      url_input=$2
      shift 2
      ;;
    -f)
      file_input=$2
      shift 2
      ;;
    -v)
      verbose=true
      shift
      ;;
    -h)
      show_help
      ;;
    *)
      echo "Parâmetro desconhecido: $1"
      show_help
      ;;
  esac
done

# Verificação de entrada obrigatória
if [[ -z "$url_input" && -z "$file_input" ]]; then
  echo "Erro: você deve fornecer uma URL com -url ou um arquivo com -f."
  show_help
fi

# Verificando onde criar o diretório de saída
if [[ -n "$file_input" && -f "$file_input" ]]; then
  output_dir=$(dirname "$file_input")/url-candidates
else
  output_dir="./url-candidates"
fi

# Criação do diretório de saída
mkdir -p "$output_dir"

# Prepara a entrada
if [[ -n "$url_input" ]]; then
  input_data=$(echo "$url_input")
elif [[ -f "$file_input" ]]; then
  input_data=$(cat "$file_input")
else
  echo "Erro: arquivo '$file_input' não encontrado."
  exit 1
fi

# Itera sobre todos os patterns .json do ~/.gf
for pattern in ~/.gf/*.json; do
  pattern_name=$(basename "$pattern" .json)

  if [[ "$verbose" == "true" ]]; then
    echo "[*] Executando gf com o pattern: $pattern_name"
  fi

  matched=$(echo "$input_data" | gf "$pattern_name")

  if [[ -n "$matched" ]]; then
    echo "$matched" > "$output_dir/$pattern_name.txt"
    # Mensagem de sucesso em verde
    echo -e "${GREEN}[+] Encontrado! Resultados salvos em $output_dir/$pattern_name.txt${RESET}"
  else
    if [[ "$verbose" == "true" ]]; then
      echo "[-] Nenhum resultado para $pattern_name"
    fi
  fi
done
