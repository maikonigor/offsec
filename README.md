Claro! Aqui está um modelo de `README.md` para o seu repositório no GitHub. Ele pode ser personalizado conforme você adicionar mais scripts e informações ao longo do seu processo de aprendizagem.

---

# **Scripts de Ethical Hacking**

Este repositório contém diversos scripts que fazem parte do meu processo de aprendizagem de **Ethical Hacking**. O foco é automatizar tarefas comuns de segurança, como varredura de subdomínios, mapeamento de URLs, filtragem e análise de padrões.

Os scripts são projetados para facilitar a execução de tarefas durante testes de penetração (pentests) e outras atividades relacionadas à segurança cibernética.

---

## **Índice**

* [Subdomain Scan](#subdomain-scan)
* [URL Scan com GF Patterns](#url-scan-com-gf-patterns)
* [Como usar](#como-usar)
* [Pré-requisitos](#pré-requisitos)
* [Instalação](#instalação)
* [Contribuição](#contribuição)
* [Licença](#licença)

---

## **Subdomain Scan**

O script `subdomain-scan.sh` permite realizar a enumeração de subdomínios para um domínio específico usando a ferramenta **Amass**. Além disso, é possível mapear as URLs de cada subdomínio usando a ferramenta **Gau**.

**Funcionalidades**:

* Realiza a enumeração de subdomínios.
* Mapeia as URLs usando o `gau`.
* Suporta a exibição de resultados em modo verbose.
* Permite salvar os resultados em diretórios específicos.

### **Exemplo de uso**:

```bash
./subdomain-scan.sh -url fabianovasconcelos.com -dir ~/test-scan -v
```

---

## **URL Scan com GF Patterns**

O script `url-scan.sh` permite escanear uma URL (ou uma lista de URLs de um arquivo) utilizando **patterns** do `GF`. Ele encontra URLs candidatas e as salva em um diretório específico, com a possibilidade de exibir os resultados em modo **verbose**.

**Funcionalidades**:

* Escaneia URLs ou arquivos de URLs usando os padrões do `gf`.
* Exibe as URLs candidatas encontradas.
* Salva os resultados em arquivos com base no padrão de busca.
* Permite o modo **verbose** para acompanhamento do progresso.

### **Exemplo de uso**:

```bash
./url-scan.sh -url 'https://example.com/index.php?page=login'
```

```bash
./url-scan.sh -f /path/to/urls.txt -v
```

---

## **Como usar**

1. **Clone o repositório**:
   Clone o repositório em sua máquina local:

   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   ```

2. **Dê permissão de execução**:
   Torne os scripts executáveis:

   ```bash
   chmod +x subdomain-scan.sh url-scan.sh
   ```

3. **Execute os scripts**:
   Agora, você pode usar os scripts para realizar a enumeração de subdomínios e escanear URLs.

   Exemplo para escanear subdomínios e mapear URLs:

   ```bash
   ./subdomain-scan.sh -url exemplo.com -dir /caminho/para/diretorio -v
   ```

   Exemplo para escanear uma URL ou arquivo com o `gf`:

   ```bash
   ./url-scan.sh -url 'https://example.com/index.php?page=login'
   ```

---

## **Pré-requisitos**

Os scripts dependem de algumas ferramentas que precisam ser instaladas previamente:

* **Amass**: Para enumeração de subdomínios.
* **Gau**: Para mapear URLs de subdomínios.
* **GF**: Para filtrar URLs com padrões.

Instale as ferramentas mencionadas antes de usar os scripts.

---

## **Instalação**

### **Amass**

1. **Instalação no Linux**:

   ```bash
   sudo apt install amass
   ```

2. **Verificação**:

   ```bash
   amass -version
   ```

---

### **Gau**

1. **Instalação no Linux**:

   ```bash
   go install github.com/lc/gau/v2/cmd/gau@latest
   ```

2. **Verificação**:

   ```bash
   gau --version
   ```

---

### **GF**

1. **Instalação**:

   Siga as instruções no repositório oficial: [https://github.com/tomnomnom/gf](https://github.com/tomnomnom/gf)

---

## **Contribuição**

Se você tiver sugestões, melhorias ou novos scripts para adicionar, fique à vontade para abrir um **Pull Request**.

1. Faça o **fork** do repositório.
2. Crie uma branch para sua feature (`git checkout -b feature/nome-da-feature`).
3. Comite suas alterações (`git commit -am 'Adicionando nova funcionalidade'`).
4. Faça o push para a branch (`git push origin feature/nome-da-feature`).
5. Abra um Pull Request.

---

## **Licença**

Este repositório está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

Esse `README.md` fornece um guia claro sobre como usar os scripts e prepara seu repositório para futuras melhorias e contribuições. Se você adicionar mais scripts ou funcionalidades, é só atualizar o arquivo conforme necessário.
