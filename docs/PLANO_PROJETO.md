# Plano de Desenvolvimento — Sistema de Ensalamento

Projeto 1 — Prática Profissional em Desenvolvimento Web / Engenharia de Software
Grupo de 4 integrantes · 8 semanas · 32 aulas

---

## 1. Decisões de arquitetura (fechadas)

| Camada | Tecnologia | Papel |
|---|---|---|
| Frontend | Volt (Bootstrap 5, HTML/CSS/JS puro) no GitHub Pages | Interface e consulta. Sem framework — não exige justificativa nem penalidade. |
| Backend | Node.js + Express, em contêiner Docker no Render | API, regras de negócio, alocação, sessão. Núcleo em JavaScript. |
| Banco | PostgreSQL gerenciado (Supabase) | Persistência de dados e histórico. |
| Autenticação | OAuth federado Google/Microsoft (no backend) | Login sem senha. Tokens nunca no localStorage. |

Regra de ouro do núcleo: as regras de conflito (RB-01 a RB-12) e o índice de adequação (6.9.2) devem ser escritos pela equipe em JavaScript puro. Nada de biblioteca que resolva alocação/otimização — isso é perda de 50%.

## 2. Fluxo de dados

GitHub Pages (Volt estático) --fetch/JSON--> Render (Express API) --> Supabase (PostgreSQL).
O localStorage guarda só a preferência de turma do aluno, nunca token. Toda permissão é verificada no servidor.

## 3. Divisão por pessoa (4 frentes)

- Pessoa A — Administrador do repositório + Infraestrutura: branch main protegida, PRs, README/LICENSE/.gitignore, segredos em variáveis de ambiente, Docker, deploy Render, projeto Supabase, GitHub Pages. Cobre infraestrutura (11 pts) e processo (7 pts).
- Pessoa B — Autenticação, papéis e dados: login Google/Microsoft (RF-01..04), sessão segura, preferência de turma (RF-05..09), modelagem do banco (6.15), importação CSV com relatório de erros (RF-10..14).
- Pessoa C — Núcleo de ensalamento (JavaScript puro, sem biblioteca): regras RB-01..12, filtro de salas válidas e índice de adequação (RF-21..27, 6.9.2), geração de proposta e explicação, validação/publicação/versionamento (RF-28..34), testes automatizados.
- Pessoa D — Frontend/experiência (Volt): interfaces mínimas (6.14), agenda diária/semanal aluno e professor (RF-35..41), painéis coordenador e admin, página da sala, acessibilidade (6.16.1), área "Sobre" (5.4).

A partir da semana 4, quem terminar ajuda o núcleo (Pessoa C). Registrar tudo em commits/PRs com mensagem descritiva.

## 4. Cronograma (Marco A = aula 12; Marco B = aula 24; cada marco perdido = -10%)

- Semana 1: setup das 3 camadas + repositório. Volt no Pages chamando a API no Render que lê o Supabase.
- Semana 2: autenticação federada + modelo de dados.
- Semana 3: cadastros e importação CSV.
- Semana 4 (Marco A): aluno escolhe turma e vê agenda; professor vê o dia. Fluxo ponta a ponta.
- Semana 5: núcleo RB-01..12 com testes.
- Semana 6 (Marco B): geração de proposta, publicação e versionamento; rascunho invisível.
- Semana 7: mudanças pós-publicação, acessibilidade, área "Sobre".
- Semana 8: extensões, documentação completa, ensaio da prova de autoria.

## 5. O que fazer por agora

1. Reunião: fechar papéis, criar repositório do grupo, definir Pessoa A como administradora.
2. Pessoa A: mover Volt para frontend/, criar backend/ e docs/, README, LICENSE, proteger main.
3. Pessoa A: criar Render e Supabase; backend Express mínimo com rota /health.
4. Pessoa B: desenhar o modelo de dados (6.15) para o grupo aprovar.
5. Pessoa C: escrever funções puras de regra (salaTemCapacidade, haSobreposicao, salaTemRecursos) com testes, sem banco.
6. Pessoa D: mapear telas da 6.14 para páginas do Volt e montar navegação vazia.

## 6. Riscos e penalidades

- Segredo no repositório: -20%. Use variáveis de ambiente.
- Biblioteca de terceiros no núcleo: -50%.
- Marco A ou B não cumprido: -10% cada.
- Sistema fora do ar na entrega: não entregue.
- Commits "update"/"fix"/"asdf" não contam como participação.
- Contribuição desequilibrada > 15%: -30%.

## 7. Como passar de 7 para 10

Os 70 primeiros pontos = fazer tudo impecável = nota 7. Os 30 restantes vêm de iniciativa própria: painel de ocupação das salas, notificações quando a sala muda, comparação de cenários, cobertura de testes e acessibilidade acima do mínimo (com medição), e discussão ética profunda sobre vieses, consequência de erro e comparação de arquiteturas.
