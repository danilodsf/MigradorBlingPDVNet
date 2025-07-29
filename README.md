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
  - `Adapter`
  - `Strategy`
- **Clean Code**: foco em legibilidade e manutenção
- **MVC**: separação de responsabilidades por camadas

---

## 📚 Tecnologias e ferramentas

- **Delphi (Tokyo ou superior)**
- **FireDAC** (para acesso ao SQLite e SQL Server)
- **BOSS** – Gerenciador de dependências para Delphi
- **Horse** – Framework HTTP para o servidor OAuth
- **RESTRequest4Delphi** – Cliente HTTP REST
- **SQLite** – Banco local
- **SQL Server** – Fonte de dados principal
- **UPX** – Compactação do executável

---

## ⚙️ Instalação e execução

### 1. Clonar o repositório

```bash
git clone https://github.com/danilodsf/MigradorBlingPDVNet.git
cd MigradorBlingPDVNet
```

### 2. Instalar o BOSS (caso não tenha)

#### 🔸 Instalação via NPM (Node.js necessário):

```bash
npm install -g @hashload/boss
```

#### 🔸 Ou baixe o executável

Acesse: https://github.com/HashLoad/boss/releases

E adicione o executável ao PATH do sistema, se desejar.

### 3. Instalar as dependências

Execute no terminal:

```bash
boss install
```

Isso criará a pasta `modules/` e instalará:

- Horse
- RESTRequest4Delphi
- Outras dependências descritas no `boss.json`

> ⚠️ O arquivo `boss-lock.json` garante que as **mesmas versões** das libs sejam instaladas.

### 4. Abrir o projeto no Delphi

- Localize e abra o arquivo `MigradorBling.dproj` (ou nome equivalente) na IDE Delphi.
- Compile normalmente.
- Execute o programa.

---

## 🧾 Funcionamento do banco de dados

- O banco local SQLite é criado automaticamente se não existir.
- Toda a estrutura (tabelas e índices) é gerada na primeira execução.
- Se um novo campo for adicionado no código e não existir no banco, ele será criado dinamicamente com `ALTER TABLE`.

---

## 📁 Estrutura do projeto

```
├─ assets                 ← Imagens e ícone do programa
├─ src/                       ← Código-fonte
├─ bin/                       ← Executável
├─ bin/db                     ← Banco de Dados SQLite
├─ boss.json                  ← Dependências do projeto
├─ boss-lock.json             ← Hashes exatos das dependências
├─ README.md                  ← Este arquivo
├─ .gitignore                 ← Ignora /modules e arquivos desnecessários
└─ modules/                   ← Instalado via BOSS (não precisa versionar)
```

---

## 🛡️ Segurança

- ✅ Mutex impede mais de uma instância do processo.
- 🔐 Token OAuth salvo com segurança e atualizado automaticamente.
- 💾 Backup diário da base SQLite feito com thread separada.

---

## 👨‍💻 Contribuindo

Contribuições são bem-vindas! Para colaborar com o projeto, siga este fluxo:

1. **Fork** o repositório
2. **Crie uma branch baseada na `develop`** para sua feature ou correção:

```
   git checkout develop
   git pull origin develop
   git checkout -b minha-feature
```   
3. **Faça seus commits normalmente:**

```
git commit -m "Minha contribuição"
```

4. **Envie sua branch para seu fork:**
```
git push origin minha-feature
```

5. Crie um **Pull Request** para a branch _develop_, e não para a _main_.
- ⚠️ Todas as contribuições devem partir da branch develop. A main é protegida e usada apenas para versões estáveis e publicações.
---

## 📄 Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo `LICENSE`.

---

## ✍️ Autor

**Danilo Fois**  
📺 Canal YouTube: [@danilofois](https://www.youtube.com/@danilofoistecnologiaavancada)

---

## 📌 Observações finais

- **O arquivo de banco SQLite é criado automaticamente** na primeira execução. 
- **Use UPX manualmente** após compilar para gerar o executável compactado (opcional).

---
