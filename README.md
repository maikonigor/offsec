---

# **Scripts de Ethical Hacking**

Este repositório contém diversos scripts que fazem parte do meu processo de aprendizagem de **Ethical Hacking**. O foco é automatizar tarefas comuns de segurança, como varredura de subdomínios, mapeamento de URLs, filtragem e análise de padrões.

Os scripts são projetados para facilitar a execução de tarefas durante testes de penetração (pentests) e outras atividades relacionadas à segurança cibernética.

Scripts para automação de recon DNS e varredura de vulnerabilidades utilizando ferramentas da stack ProjectDiscovery.

## Estrutura

```text
bugbounty/
├── recon.sh
├── vulnscan.sh
└── README.md
```

---

# Recon DNS

Script responsável por:

- Enumerar subdomínios usando `subfinder`
- Executar brute force DNS com `shuffleDNS` (opcional)
- Salvar resultados organizados por domínio

## Ferramentas utilizadas

- subfinder
- shuffledns
- anew
- GNU parallel

## Estrutura esperada

```text
/home/kali/bugbounty/
└── company/
    └── domains.txt
```

Exemplo de `domains.txt`:

```text
example.com
test.com
```

## Uso

### Apenas enumeração passiva

```bash
./recon.sh
```

### Enumeração + brute force DNS

```bash
./recon.sh --brute
```

## Output

```text
company/
└── domains/
    └── example.com/
        ├── subs.txt
        └── brute_dns.txt
```

---

# Vulnerability Scan

Script responsável por:

- Buscar todos os arquivos `subs.txt`
- Executar templates high/critical do nuclei
- Salvar findings por domínio
- Enviar notificações usando `notify`

## Ferramentas utilizadas

- nuclei
- anew
- notify
- GNU parallel

## Uso

```bash
./vulnscan.sh
```

## Output

```text
company/
└── domains/
    └── example.com/
        ├── subs.txt
        └── nuclei_out.txt
```

---

# Dependências

## Instalação das ferramentas

### ProjectDiscovery

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest

go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

go install -v github.com/projectdiscovery/notify/cmd/notify@latest
```

### Anew

```bash
go install -v github.com/tomnomnom/anew@latest
```

### GNU Parallel

```bash
sudo apt install parallel
```

---

# Wordlists

O brute force DNS utiliza:

```text
/usr/share/wordlists/SecLists/Discovery/DNS/dns-Jhaddix.txt
```

Resolvers:

```text
/usr/share/wordlists/resolvers/resolvers.txt
```

---

# Permissões

Não esqueça de tornar os scripts executáveis:

```bash
chmod +x recon.sh
chmod +x vulnscan.sh
```

---

# Observações

- O brute force DNS é opcional via `--brute`
- Os resultados são incrementais graças ao `anew`
- O `notify` pode ser configurado para Discord, Slack, Telegram, etc
- O `parallel -j 4` controla quantos domínios são processados simultaneamente

---

# Disclaimer

Uso exclusivo para ambientes autorizados e programas de bug bounty.
````



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
