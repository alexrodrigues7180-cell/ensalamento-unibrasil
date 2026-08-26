-- ============================================================
-- Sistema de Ensalamento — UniBrasil
-- Schema PostgreSQL (Supabase)
-- Cobre o modelo conceitual mínimo (seção 6.15) e os dados
-- que o sistema deve manter (seção 6.6) do memorial descritivo.
-- ============================================================

-- Extensão para gerar UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- BLOCO 1 — ESTRUTURA FÍSICA (seção 6.6.1)
-- ============================================================

CREATE TABLE campus (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo       TEXT NOT NULL UNIQUE,
    nome         TEXT NOT NULL,
    endereco     TEXT,
    criado_em    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE predio (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campus_id    UUID NOT NULL REFERENCES campus(id),
    codigo       TEXT NOT NULL,
    nome         TEXT NOT NULL,
    instrucoes_acesso TEXT,
    UNIQUE (campus_id, codigo)
);

CREATE TABLE sala (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    predio_id          UUID NOT NULL REFERENCES predio(id),
    codigo             TEXT NOT NULL,
    nome               TEXT,
    bloco              TEXT,
    andar              TEXT,
    -- tipo: comum, auditorio, laboratorio, atelie
    tipo               TEXT NOT NULL DEFAULT 'comum',
    capacidade         INTEGER NOT NULL CHECK (capacidade >= 0),
    capacidade_avaliacao INTEGER CHECK (capacidade_avaliacao >= 0),
    acessivel          BOOLEAN NOT NULL DEFAULT false,
    -- estado: ativo, manutencao, desativado
    estado             TEXT NOT NULL DEFAULT 'ativo',
    UNIQUE (predio_id, codigo)
);

-- Recursos que uma sala pode ter (projetor, computadores, etc.)
CREATE TABLE recurso (
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo  TEXT NOT NULL UNIQUE,
    nome    TEXT NOT NULL
);

-- Relação N:N entre sala e recurso
CREATE TABLE sala_recurso (
    sala_id     UUID NOT NULL REFERENCES sala(id),
    recurso_id  UUID NOT NULL REFERENCES recurso(id),
    quantidade  INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (sala_id, recurso_id)
);

-- Indisponibilidades temporárias de uma sala
CREATE TABLE indisponibilidade (
    id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sala_id   UUID NOT NULL REFERENCES sala(id),
    inicio    TIMESTAMPTZ NOT NULL,
    fim       TIMESTAMPTZ NOT NULL,
    motivo    TEXT,
    CHECK (fim > inicio)
);

-- ============================================================
-- BLOCO 2 — PESSOAS E PAPÉIS (seção 6.4, RF-01 a RF-04)
-- ============================================================

CREATE TABLE usuario (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- identificador estável vindo do provedor (Google/Microsoft)
    identidade_externa TEXT UNIQUE,
    email          TEXT NOT NULL UNIQUE,
    nome           TEXT,
    -- papel: admin, coordenador, professor, aluno
    papel          TEXT NOT NULL DEFAULT 'aluno',
    ativo          BOOLEAN NOT NULL DEFAULT true,
    criado_em      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- BLOCO 3 — ESTRUTURA ACADÊMICA (seção 6.6.2)
-- ============================================================

CREATE TABLE periodo_letivo (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo      TEXT NOT NULL UNIQUE,
    nome        TEXT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim    DATE NOT NULL,
    -- estado: preparacao, aberto, encerrado
    estado      TEXT NOT NULL DEFAULT 'preparacao',
    CHECK (data_fim > data_inicio)
);

CREATE TABLE curso (
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo  TEXT NOT NULL UNIQUE,
    nome    TEXT NOT NULL
);

CREATE TABLE disciplina (
    id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    curso_id  UUID NOT NULL REFERENCES curso(id),
    codigo    TEXT NOT NULL,
    nome      TEXT NOT NULL,
    UNIQUE (curso_id, codigo)
);

-- Coordenador responsável por um ou mais cursos
CREATE TABLE coordenacao (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id    UUID NOT NULL REFERENCES usuario(id),
    curso_id      UUID NOT NULL REFERENCES curso(id),
    UNIQUE (usuario_id, curso_id)
);

CREATE TABLE turma (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    periodo_id       UUID NOT NULL REFERENCES periodo_letivo(id),
    disciplina_id    UUID NOT NULL REFERENCES disciplina(id),
    codigo           TEXT NOT NULL,
    turno            TEXT,
    campus_id        UUID REFERENCES campus(id),
    qtd_prevista     INTEGER CHECK (qtd_prevista >= 0),
    qtd_confirmada   INTEGER CHECK (qtd_confirmada >= 0),
    -- estado: rascunho, enviada, em_revisao, aprovada, cancelada, encerrada
    estado           TEXT NOT NULL DEFAULT 'rascunho',
    UNIQUE (periodo_id, disciplina_id, codigo)
);

-- Professores vinculados a uma turma (N:N)
CREATE TABLE turma_professor (
    turma_id     UUID NOT NULL REFERENCES turma(id),
    usuario_id   UUID NOT NULL REFERENCES usuario(id),
    PRIMARY KEY (turma_id, usuario_id)
);

-- Encontros: ocorrências recorrentes ou excepcionais de uma turma
CREATE TABLE encontro (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    turma_id      UUID NOT NULL REFERENCES turma(id),
    -- dia_semana: 1=segunda ... 7=domingo (NULL se for data excepcional)
    dia_semana    SMALLINT CHECK (dia_semana BETWEEN 1 AND 7),
    data_excepcional DATE,
    hora_inicio   TIME NOT NULL,
    hora_fim      TIME NOT NULL,
    CHECK (hora_fim > hora_inicio)
);

-- ============================================================
-- BLOCO 4 — NECESSIDADES E PREFERÊNCIAS (RF-15 a RF-20)
-- ============================================================

CREATE TABLE necessidade (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    turma_id      UUID NOT NULL REFERENCES turma(id),
    recurso_id    UUID REFERENCES recurso(id),
    -- tipo: obrigatoria, preferencial
    tipo          TEXT NOT NULL DEFAULT 'obrigatoria',
    -- descricao livre para acessibilidade ou pedidos especiais
    descricao     TEXT,
    justificativa TEXT
);

-- ============================================================
-- BLOCO 5 — ENSALAMENTO, VERSÕES E AUDITORIA (seção 6.6.3)
-- ============================================================

CREATE TABLE versao (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    periodo_id    UUID NOT NULL REFERENCES periodo_letivo(id),
    numero        INTEGER NOT NULL,
    -- estado: rascunho, publicada, arquivada
    estado        TEXT NOT NULL DEFAULT 'rascunho',
    descricao     TEXT,
    responsavel_id UUID REFERENCES usuario(id),
    publicada_em  TIMESTAMPTZ,
    UNIQUE (periodo_id, numero)
);

-- Alocação: associação entre um encontro e uma sala, dentro de uma versão
CREATE TABLE alocacao (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    versao_id     UUID NOT NULL REFERENCES versao(id),
    encontro_id   UUID NOT NULL REFERENCES encontro(id),
    sala_id       UUID REFERENCES sala(id),
    -- origem: automatica, manual
    origem        TEXT NOT NULL DEFAULT 'automatica',
    justificativa TEXT,
    -- estado: alocada, pendente, cancelada
    estado        TEXT NOT NULL DEFAULT 'alocada',
    UNIQUE (versao_id, encontro_id)
);

-- Registro de auditoria: cada alteração publicada (RB-12)
CREATE TABLE auditoria (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tabela        TEXT NOT NULL,
    registro_id   UUID NOT NULL,
    autor_id      UUID REFERENCES usuario(id),
    motivo        TEXT,
    valor_anterior JSONB,
    valor_novo    JSONB,
    criado_em     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- ÍNDICES úteis para consulta rápida (RNF de desempenho)
-- ============================================================

CREATE INDEX idx_turma_periodo ON turma(periodo_id);
CREATE INDEX idx_encontro_turma ON encontro(turma_id);
CREATE INDEX idx_alocacao_versao ON alocacao(versao_id);
CREATE INDEX idx_alocacao_sala ON alocacao(sala_id);
CREATE INDEX idx_sala_predio ON sala(predio_id);

-- ============================================================
-- FIM DO SCHEMA
-- ============================================================
