# 🔄 Migrador Bling – Integração PDVNET ⇄ Bling ERP

Projeto em Delphi para realizar a **sincronização de produtos, estoques e variações** do sistema **PDV NET (SQL Server)** para o **ERP Bling**, utilizando autenticação OAuth, banco de dados local em SQLite e diversas boas práticas de arquitetura de software.

---

## 🚀 Funcionalidades

- 🔁 Sincronização completa de produtos, estoques e variações  
- 🔐 Autenticação OAuth com refresh automático via servidor HTTP (Horse)  
- 🌐 Integração via API REST do Bling usando RESTRequest4Delphi  
- 💾 Banco local em SQLite criado e versionado automaticamente  
- 🧱 Criação automática de colunas que estejam ausentes no banco  
- 📦 Gerenciamento de dependências com BOSS  
- 🔄 Backup automático do banco com thread dedicada  
- 🔒 Mutex para impedir múltiplas instâncias simultâneas  
- 🧳 Executável compactado com UPX  
- ✅ Projeto sem _hints_ ou _warnings_

---

## 🧠 Arquitetura e boas práticas

- **Padrões de projeto aplicados**:  
  - `Observer`  
  - `Singleton`  
  - `Factory`  
  - `Prototype`  
  - `Adapter` (para abstrair diferentes camadas de conexão, como ADO ou FireDAC)  
  - `Strategy`  

- **Camada de Adapter**:  
  O projeto utiliza um **Adapter de conexão**, permitindo alternar entre ADO e FireDAC.  
  - Uso de `includes` para habilitar o FireDAC para SQL Server quando disponível.  
  - Mantém o mesmo contrato da interface `IConexao`, permitindo escalabilidade e fácil manutenção.

- **Clean Code**: foco em legibilidade e manutenção  
- **MVC**: separação de responsabilidades por camadas

---

## 🔐 Segurança

- Variáveis sensíveis, como **credenciais de conexão** e **chaves da API**, são obtidas via **variáveis de ambiente**.  
- Tokens OAuth são armazenados de forma segura e atualizados automaticamente.  
- Mutex para impedir múltiplas instâncias do processo.  
- Backup diário da base SQLite feito em **thread separada**.

---

## 📚 Tecnologias e ferramentas

- **Delphi (Tokyo ou superior)**  
- **FireDAC** – Conexão com SQLite e opcionalmente SQL Server via driver nativo ou ODBC*  
- **ADO** – Suporte para SQL Server em versões do Delphi sem driver FireDAC nativo  
- **BOSS** – Gerenciador de dependências para Delphi  
- **Horse** – Framework HTTP para o servidor OAuth  
- **RESTRequest4Delphi** – Cliente HTTP REST  
- **SQLite** – Banco local  
- **SQL Server** – Fonte de dados principal  
- **UPX** – Compactação do executável  

> **Nota:** O uso de FireDAC para SQL Server depende da edição do Delphi ou de drivers adicionais.  
> **Importante:** Caso opte por **ADO**, é necessário instalar o driver **Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL)**, disponível aqui:  
> [https://learn.microsoft.com/sql/connect/oledb/download-oledb-driver-for-sql-server](https://learn.microsoft.com/sql/connect/oledb/download-oledb-driver-for-sql-server)

---

## ⚙️ Instalação e execução

### 1. Clonar o repositório

```bash
git clone https://github.com/danilodsf/MigradorBlingPDVNet.git
cd MigradorBlingPDVNet
```

### 2. Configurar variáveis de ambiente

Antes de compilar, configure no sistema:  
- **PDVNET_SERVER** – Endereço ou instância do SQL Server  
- **PDVNET_USER** – Usuário de conexão  
- **PDVNET_PASS** – Senha de conexão  

No Windows PowerShell:
```powershell
setx PDVNET_SERVER "SERVIDOR\INSTANCIA"
setx PDVNET_USER "usuario"
setx PDVNET_PASS "senha"
```

---

### 3. Instalar o BOSS (caso não tenha)

#### 🔸 Instalação via NPM:
```bash
npm install -g @hashload/boss
```

#### 🔸 Ou baixe o executável:
https://github.com/HashLoad/boss/releases

---

### 4. Instalar as dependências

```bash
boss install
```

---

### 5. Abrir o projeto no Delphi

Abra o arquivo `MigradorBling.dproj` e compile.

---

## 🧾 Funcionamento do banco de dados

- O banco SQLite é criado automaticamente na primeira execução.  
- Novas colunas ausentes são adicionadas via `ALTER TABLE`.  

---

## 📁 Estrutura do projeto

```
├─ assets                 ← Imagens e ícone do programa
├─ src/                   ← Código-fonte
├─ bin/                   ← Executável
├─ bin/db                 ← Banco de Dados SQLite
├─ boss.json              ← Dependências do projeto
├─ boss-lock.json         ← Hashes exatos das dependências
├─ README.md              ← Este arquivo
├─ .gitignore             ← Ignora /modules e arquivos desnecessários
└─ modules/               ← Instalado via BOSS (não precisa versionar)
```

---

## 👨‍💻 Contribuindo

1. **Fork** o repositório  
2. **Crie uma branch baseada na `develop`**  
3. Faça commits claros e objetivos  
4. Envie a branch para seu fork  
5. Crie um Pull Request para `develop`

---

## 📄 Licença

Licenciado sob **MIT**. Consulte `LICENSE`.

---

## ✍️ Autor

**Danilo Fois**  
📺 Canal YouTube: [@danilofois](https://www.youtube.com/@danilofoistecnologiaavancada)
