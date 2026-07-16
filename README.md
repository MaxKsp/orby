<h1 align="center">Orby</h1>

<p align="center">
  <b>Rotina, finanças pessoais, treinos e organização diária em um único painel self-hosted.</b>
</p>

<p align="center">
  <a href="https://github.com/MaxKsp/orby/actions/workflows/tests.yml">
    <img src="https://github.com/MaxKsp/orby/actions/workflows/tests.yml/badge.svg" alt="Testes automatizados" />
  </a>
  <img src="https://img.shields.io/badge/PHP-8%2B-777BB4?style=flat&logo=php&logoColor=white" alt="PHP 8+" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/JavaScript-Vanilla-F7DF1E?style=flat&logo=javascript&logoColor=black" alt="JavaScript" />
  <img src="https://img.shields.io/badge/PWA-ready-5A0FC8?style=flat&logo=pwa&logoColor=white" alt="PWA" />
  <img src="https://img.shields.io/badge/2FA-TOTP-informational?style=flat" alt="2FA TOTP" />
  <img src="https://img.shields.io/badge/Backup-criptografado-success?style=flat" alt="Backup criptografado" />
  <img src="https://img.shields.io/badge/Self--Hosted-000000?style=flat" alt="Self-hosted" />
</p>

---

## Sobre o Projeto

O **Orby** é uma aplicação web pessoal para centralizar rotina, finanças, treinos, metas e preferências em uma única experiência. A ideia é substituir a dependência de várias planilhas e aplicativos isolados por um painel próprio, instalável como PWA e preparado para rodar em hospedagem compartilhada comum.

O projeto foi pensado para uso real, mas também como base técnica evolutiva: possui autenticação, multiusuário, 2FA, API própria em PHP, MySQL, deploy automatizado, testes, contratos de schema e backup/restauração criptografados.

**Proposta:** entregar uma experiência prática de organização pessoal com uma arquitetura simples de operar, barata de hospedar e segura o suficiente para evoluir como produto.

---

## Status Atual

| Área | Status |
|---|---|
| Financeiro pessoal | Em uso e evolução contínua |
| Rotina e agenda | Funcional |
| Treinos e medidas | Funcional |
| Multiusuário | Implementado |
| 2FA TOTP | Implementado |
| Login com Google | Implementado |
| PWA | Implementado |
| Testes automatizados | Implementado em PHP e JavaScript |
| Backup criptografado | Implementado |
| Deploy via GitHub Actions | Implementado |
| Modelo de assinatura | Base inicial implementada |

---

## Funcionalidades

### Financeiro

- Visão consolidada de saldo, patrimônio, faturas e crédito disponível.
- Cadastro de contas, cartões, bancos, receitas e despesas.
- Cards de conta/cartão com informações de saldo, limite, fatura, vencimento e melhor dia de compra.
- Despesas avulsas, recorrentes e parceladas.
- Transferência entre contas.
- Pagamento de fatura de cartão com conta.
- Cofrinhos/metas de guardar dinheiro por conta.
- Cheque especial por conta, com limite e alerta de uso.
- Rendas fixas, temporárias e variáveis.
- Importação e conciliação por extrato bancário OFX.
- Busca e filtros em lançamentos.
- Gráficos, análises, mapa de calor e histórico mensal.
- Relatório anual para IR.
- Visão por conta, banco e categoria.

### Rotina

- Agenda semanal.
- Checklist diário.
- Sequência de dias concluídos.
- Gráficos de progresso.
- Mapa de calor de conclusão.
- Lembretes e notificações.

### Treinos

- Cadastro de treinos e exercícios.
- Checklist do treino do dia.
- Registro de carga e progressão.
- Medidas corporais.
- Peso, IMC e acompanhamento de evolução.

### Plataforma

- Multiusuário com dados isolados por conta.
- Login com senha.
- Login com Google OAuth.
- Verificação em duas etapas com TOTP.
- Códigos de backup para recuperação do 2FA.
- Preferências sincronizadas por usuário.
- Temas e ajustes de perfil.
- PWA instalável.
- Deploy automatizado.
- Rotinas operacionais de backup e restauração.

---

## Diferenciais Técnicos

- **Sem framework pesado:** PHP, MySQL e JavaScript vanilla.
- **Hospedagem simples:** projetado para rodar em hospedagem compartilhada.
- **API própria:** endpoints PHP organizados por responsabilidade.
- **Segurança aplicada:** CSRF, rate limit, 2FA, isolamento por usuário e headers de proteção.
- **Operação real:** deploy via GitHub Actions, scripts de manutenção e CI.
- **Backup seguro:** artefato criptografado com libsodium e restore validado.
- **Contratos de schema:** validação de estrutura para reduzir risco operacional.
- **Testes automatizados:** suíte PHP e validações JavaScript no pipeline.

---

## Stack

| Camada | Escolha |
|---|---|
| Front-end | HTML, CSS e JavaScript vanilla |
| Gráficos | Chart.js |
| Back-end | PHP 8+ |
| Banco de dados | MySQL |
| Acesso a dados | PDO com prepared statements |
| Autenticação | Sessão PHP, bcrypt, Google OAuth e TOTP |
| Segurança | CSRF, rate limit, headers, isolamento por usuário |
| PWA | Manifest + Service Worker |
| CI | GitHub Actions |
| Deploy | GitHub Actions + FTPS |
| Backup | PHP + libsodium secretstream |

---

## Segurança

O projeto já possui uma base de segurança aplicada:

- senhas com hash seguro;
- proteção CSRF em fluxos sensíveis;
- verificação em duas etapas com TOTP;
- códigos de backup para 2FA;
- dados isolados por usuário;
- rate limit em autenticação e endpoints sensíveis;
- `config.php` fora do versionamento;
- headers de proteção via `.htaccess`;
- backup criptografado com chave fora do repositório;
- restore com validação de alvo para evitar sobrescrever o banco da aplicação.

---

## Backup e Restauração Criptografados

O Orby possui uma rotina de backup e restore voltada para operação segura.

O artefato de backup utiliza:

- container versionado;
- criptografia com `libsodium secretstream`;
- chave obrigatória via variável de ambiente `ORBY_BACKUP_KEY`;
- contrato de tabelas persistentes e efêmeras;
- validação do schema antes de gerar ou restaurar;
- restore em duas passagens: validação do artefato e restauração transacional;
- proteção contra restauração acidental no banco da aplicação;
- teste automatizado cobrindo corrupção, chave errada, rollback e isolamento.

Arquivos principais:

```text
app/Core/BackupCrypto.php
app/Core/DatabaseBackup.php
app/Core/DatabaseRestore.php
app/Core/SchemaAuditor.php
config/backup-contract.php
config/schema-contract.php
scripts/backup.php
scripts/restore.php
tests/cases/backup_recovery_test.php
```

Variáveis de ambiente usadas pelo backup/restore:

| Variável | Uso |
|---|---|
| `ORBY_BACKUP_KEY` | chave base64 de 32 bytes para criptografar/decriptar backups |
| `ORBY_RESTORE_DB_HOST` | host do banco isolado de restauração |
| `ORBY_RESTORE_DB_NAME` | nome do banco isolado de restauração |
| `ORBY_RESTORE_DB_USER` | usuário do banco de restauração |
| `ORBY_RESTORE_DB_PASS` | senha do banco de restauração |
| `ORBY_RESTORE_CONFIRM_NAME` | confirmação exata do banco alvo |

Gerar chave:

```bash
php -r "echo base64_encode(random_bytes(SODIUM_CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES)), PHP_EOL;"
```

---

## Estrutura

```text
api/                       Endpoints da aplicação
app/Core/                  Componentes centrais e serviços internos
assets/                    CSS, JavaScript e imagens
automation/                Arquivos auxiliares de automação
config/                    Contratos de backup e schema
docs/                      Documentação técnica e relatórios
migrations/                Migrações de banco
scripts/                   Scripts operacionais
tests/                     Testes automatizados
uploads/                   Arquivos enviados pelo usuário

auth.php                   Sessão, login, CSRF e 2FA
db.php                     Conexão PDO
finance.php                Regras do módulo financeiro
index.php                  Aplicação principal
plan.php                   Base de planos/assinatura
schema.sql                 Schema inicial
config.example.php         Exemplo de configuração local
```

---

## Rodando Localmente

Requisitos:

- PHP 8+
- MySQL
- extensões PHP: `pdo_mysql`, `mbstring`, `json`
- para backup criptografado: `sodium`

Passos básicos:

```bash
cp config.example.php config.php
php -S localhost:8080
```

Depois:

1. Crie um banco MySQL.
2. Rode o `schema.sql`.
3. Ajuste as credenciais no `config.php`.
4. Acesse `http://localhost:8080`.

---

## Testes

Rodar a suíte PHP:

```bash
php tests/run.php
```

Validar sintaxe de um arquivo PHP:

```bash
php -l arquivo.php
```

O workflow `.github/workflows/tests.yml` valida PHP e JavaScript nos PRs.

---

## Deploy

O deploy é feito por GitHub Actions via FTPS para hospedagem compartilhada.

Secrets esperados:

| Secret | Valor |
|---|---|
| `FTP_SERVER` | servidor FTP/FTPS |
| `FTP_USERNAME` | usuário FTP |
| `FTP_PASSWORD` | senha FTP |
| `FTP_SERVER_DIR` | diretório remoto, geralmente `/public_html/` |

Configuração única no servidor:

1. Criar o banco e rodar `schema.sql`.
2. Criar `config.php` a partir do `config.example.php`.
3. Ativar SSL da hospedagem.
4. Definir variáveis de ambiente quando for usar backup/restore.

---

## Roadmap

O backlog priorizado vive no [ROADMAP.md](ROADMAP.md).

Frentes principais:

- evoluir o financeiro como experiência de banking app;
- aumentar cobertura de testes;
- fortalecer auditoria e trilha de eventos;
- amadurecer modelo de assinatura;
- modularizar a arquitetura gradualmente;
- melhorar operação, backup e deploy;
- preparar base para domínio próprio, e-mail transacional e recuperação de senha.

---

## Contribuindo

Fluxo sugerido:

1. Crie uma branch por melhoria.
2. Abra PR contra `master`.
3. Rode os testes antes do merge.
4. Mantenha commits pequenos e objetivos.

Convenção de commits:

`feat:` nova funcionalidade · `fix:` correção · `sec:` segurança · `ci:` pipeline · `docs:` documentação · `refactor:` reorganização.

---

<p align="center">
  Feito por <a href="https://github.com/MaxKsp">Max Keller</a>
</p>
