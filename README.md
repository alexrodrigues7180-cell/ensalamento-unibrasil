# Sistema de Ensalamento — UniBrasil

Aplicação web para organizar, publicar e consultar o ensalamento de uma universidade — a relação entre turmas, horários e salas de aula, reunida em uma única fonte oficial e atualizada.

Trabalho acadêmico da disciplina **Prática Profissional em Desenvolvimento Web — Engenharia de Software**. Este repositório não é uma publicação institucional.

---

## Arquitetura

O sistema é composto por três camadas:

| Camada | Tecnologia | Hospedagem |
|---|---|---|
| Frontend | Bootstrap 5, HTML/CSS/JS (template Volt) | GitHub Pages |
| Backend | Node.js + Express, em contêiner Docker | Render |
| Banco de dados | PostgreSQL gerenciado | Supabase |

O frontend nunca acessa o banco diretamente: ele consome a API do backend, e apenas o backend se conecta ao PostgreSQL. Toda verificação de permissão ocorre no servidor.

## Estrutura do repositório

```
ensalamento-unibrasil/
├── frontend/        Interface web (Volt) — publicada no GitHub Pages
├── backend/         API Node.js + Express
│   ├── index.js     Servidor e rotas
│   ├── Dockerfile   Empacotamento do contêiner
│   └── db/
│       └── schema.sql   Schema completo do banco (modelo conceitual, seção 6.15)
└── docs/            Plano e documentação do projeto
```

## Requisitos

- Node.js 18 ou superior
- Uma connection string de um banco PostgreSQL (ex.: Supabase)

## Execução local (backend)

1. Entre na pasta do backend e instale as dependências:
   ```bash
   cd backend
   npm install
   ```

2. Defina a variável de ambiente com a conexão do banco. Nunca coloque a senha no código — use uma variável de ambiente:
   ```bash
   export DATABASE_URL="postgresql://usuario:senha@host:porta/banco"
   ```
   (Veja `.env.example` para o formato esperado.)

3. Inicie o servidor:
   ```bash
   node index.js
   ```

4. Teste as rotas no navegador:
   - `http://localhost:3000/health` — confirma que a API está no ar
   - `http://localhost:3000/db-test` — confirma a conexão com o banco

## Execução local (frontend)

O frontend é estático. Para visualizá-lo localmente:

```bash
cd frontend
python3 -m http.server 8000
```

Acesse `http://localhost:8000`.

## Banco de dados

O schema completo está em `backend/db/schema.sql`. Para recriar o banco do zero, execute o conteúdo desse arquivo no editor SQL do provedor PostgreSQL (no Supabase: **SQL Editor** → nova query → colar → **Run**).

## Publicação

- **Backend (Render):** o deploy é automático a partir do branch `main`. O Render constrói a imagem Docker da pasta `backend/` e publica o serviço. A variável `DATABASE_URL` é configurada no painel do Render (**Environment**), nunca no repositório.
- **Frontend (GitHub Pages):** publicado a partir da pasta `frontend/` do branch `main`.

## Processo de contribuição

- O branch `main` contém a versão de produção e é protegido.
- Nenhum commit é feito diretamente no `main`: toda alteração entra por **Pull Request**, revisado e aprovado pelo administrador do repositório.
- Mensagens de commit devem ser descritivas.
- Segredos (chaves, tokens, senhas) nunca são versionados — apenas variáveis de ambiente.

## Licença

Este projeto usa a licença MIT. Veja o arquivo `LICENSE`.

## Equipe

(preencher com nome e papel de cada integrante)
