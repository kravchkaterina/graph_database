USE master;
GO
DROP DATABASE IF EXISTS KnowledgeBase;
GO
CREATE DATABASE KnowledgeBase
    COLLATE Cyrillic_General_CI_AS;
GO
USE KnowledgeBase;
GO

CREATE TABLE Article
(
    id               INT           NOT NULL PRIMARY KEY,
    title            NVARCHAR(200) NOT NULL,
    content          NVARCHAR(MAX) NOT NULL,
    created_date     DATE          NOT NULL,
    author           NVARCHAR(100) NOT NULL,
    views            INT           NOT NULL DEFAULT 0
) AS NODE;
GO

CREATE TABLE Tag
(
    id               INT           NOT NULL PRIMARY KEY,
    name             NVARCHAR(50)  NOT NULL UNIQUE,
    description      NVARCHAR(500) NULL,
    usage_count      INT           NOT NULL DEFAULT 0
) AS NODE;
GO

CREATE TABLE Category
(
    id               INT           NOT NULL PRIMARY KEY,
    name             NVARCHAR(50)  NOT NULL UNIQUE,
    parent_category  NVARCHAR(50)  NULL
) AS NODE;
GO

CREATE TABLE [References]
(
    reference_type   NVARCHAR(30)  NOT NULL,
    weight           INT           NOT NULL DEFAULT 1,
    created_date     DATE          NOT NULL
) AS EDGE;
GO

ALTER TABLE [References]
    ADD CONSTRAINT EC_References CONNECTION (Article TO Article);
GO

CREATE TABLE Tagged
(
    assigned_date    DATE          NOT NULL,
    relevance_score  DECIMAL(5,2)  NOT NULL DEFAULT 1.0
) AS EDGE;
GO

ALTER TABLE Tagged
    ADD CONSTRAINT EC_Tagged CONNECTION (Article TO Tag);
GO

CREATE TABLE BelongsTo
(
    main_category    BIT           NOT NULL DEFAULT 0
) AS EDGE;
GO

ALTER TABLE BelongsTo
    ADD CONSTRAINT EC_BelongsTo CONNECTION (Article TO Category);
GO

INSERT INTO Article (id, title, content, created_date, author, views)
VALUES
    (1,  N'Введение в базы данных', 
     N'База данных — это организованная структура для хранения и управления информацией...', 
     '2024-01-15', N'Иван Петров', 1520),
    (2,  N'SQL для начинающих', 
     N'SQL (Structured Query Language) — язык запросов к реляционным базам данных...', 
     '2024-01-20', N'Мария Сидорова', 2350),
    (3,  N'Нормализация баз данных', 
     N'Нормализация — процесс организации данных для уменьшения избыточности...', 
     '2024-02-01', N'Иван Петров', 890),
    (4,  N'Индексы и производительность', 
     N'Индексы ускоряют поиск данных, но замедляют операции вставки и обновления...', 
     '2024-02-10', N'Алексей Смирнов', 1200),
    (5,  N'Транзакции и ACID', 
     N'ACID — свойства транзакций: Атомарность, Согласованность, Изоляция, Долговечность...', 
     '2024-02-15', N'Мария Сидорова', 980),
    (6,  N'NoSQL базы данных', 
     N'NoSQL — широкий класс баз данных, отличающихся от реляционных...', 
     '2024-03-01', N'Дмитрий Козлов', 2100),
    (7,  N'Графовые базы данных', 
     N'Графовые БД используют структуры узлов и рёбер для представления данных...', 
     '2024-03-10', N'Елена Новикова', 750),
    (8,  N'Введение в PostgreSQL', 
     N'PostgreSQL — мощная объектно-реляционная СУБД с открытым кодом...', 
     '2024-03-15', N'Иван Петров', 3100),
    (9,  N'Введение в MongoDB', 
     N'MongoDB — документо-ориентированная NoSQL база данных...', 
     '2024-03-20', N'Дмитрий Козлов', 2800);
GO

INSERT INTO Tag (id, name, description, usage_count)
VALUES
    (1,  N'SQL',           N'Язык структурированных запросов', 0),
    (2,  N'NoSQL',         N'Не только SQL', 0),
    (3,  N'реляционные',   N'Реляционные базы данных', 0),
    (4,  N'графовые',      N'Графовые базы данных', 0),
    (5,  N'производительность', N'Оптимизация и производительность БД', 0),
    (6,  N'транзакции',    N'Работа с транзакциями', 0),
    (7,  N'индексы',       N'Индексирование данных', 0),
    (8,  N'нормализация',  N'Нормализация баз данных', 0),
    (9,  N'PostgreSQL',    N'СУБД PostgreSQL', 0),
    (10, N'MongoDB',       N'СУБД MongoDB', 0);
GO

INSERT INTO Category (id, name, parent_category)
VALUES
    (1,  N'Основы БД',       NULL),
    (2,  N'Теория БД',       N'Основы БД'),
    (3,  N'Практика SQL',    N'Основы БД'),
    (4,  N'Реляционные СУБД', N'Основы БД'),
    (5,  N'NoSQL СУБД',      N'Основы БД'),
    (6,  N'Оптимизация',     N'Теория БД'),
    (7,  N'Администрирование', N'Практика SQL');
GO

INSERT INTO [References] (reference_type, weight, created_date, $from_id, $to_id)
VALUES
    (N'internal', 3, '2024-01-15',
        (SELECT $node_id FROM Article WHERE id=1),
        (SELECT $node_id FROM Article WHERE id=2)),
    (N'internal', 2, '2024-01-20',
        (SELECT $node_id FROM Article WHERE id=2),
        (SELECT $node_id FROM Article WHERE id=3)),
    (N'related',  2, '2024-02-01',
        (SELECT $node_id FROM Article WHERE id=3),
        (SELECT $node_id FROM Article WHERE id=4)),
    (N'internal', 3, '2024-02-10',
        (SELECT $node_id FROM Article WHERE id=4),
        (SELECT $node_id FROM Article WHERE id=5)),
    (N'related',  1, '2024-02-15',
        (SELECT $node_id FROM Article WHERE id=5),
        (SELECT $node_id FROM Article WHERE id=2)),
    (N'external', 1, '2024-03-01',
        (SELECT $node_id FROM Article WHERE id=6),
        (SELECT $node_id FROM Article WHERE id=7)),
    (N'internal', 2, '2024-03-10',
        (SELECT $node_id FROM Article WHERE id=7),
        (SELECT $node_id FROM Article WHERE id=2)),
    (N'related',  2, '2024-03-15',
        (SELECT $node_id FROM Article WHERE id=8),
        (SELECT $node_id FROM Article WHERE id=2)),
    (N'related',  2, '2024-03-20',
        (SELECT $node_id FROM Article WHERE id=9),
        (SELECT $node_id FROM Article WHERE id=6)),
    (N'internal', 1, '2024-03-25',
        (SELECT $node_id FROM Article WHERE id=1),
        (SELECT $node_id FROM Article WHERE id=5));
GO

INSERT INTO Tagged (assigned_date, relevance_score, $from_id, $to_id)
VALUES
    ('2024-01-15', 1.0, (SELECT $node_id FROM Article WHERE id=1), (SELECT $node_id FROM Tag WHERE name=N'SQL')),
    ('2024-01-15', 0.8, (SELECT $node_id FROM Article WHERE id=1), (SELECT $node_id FROM Tag WHERE name=N'реляционные')),
    ('2024-01-20', 1.0, (SELECT $node_id FROM Article WHERE id=2), (SELECT $node_id FROM Tag WHERE name=N'SQL')),
    ('2024-01-20', 0.9, (SELECT $node_id FROM Article WHERE id=2), (SELECT $node_id FROM Tag WHERE name=N'производительность')),
    ('2024-02-01', 1.0, (SELECT $node_id FROM Article WHERE id=3), (SELECT $node_id FROM Tag WHERE name=N'нормализация')),
    ('2024-02-01', 0.7, (SELECT $node_id FROM Article WHERE id=3), (SELECT $node_id FROM Tag WHERE name=N'реляционные')),
    ('2024-02-10', 1.0, (SELECT $node_id FROM Article WHERE id=4), (SELECT $node_id FROM Tag WHERE name=N'индексы')),
    ('2024-02-10', 1.0, (SELECT $node_id FROM Article WHERE id=4), (SELECT $node_id FROM Tag WHERE name=N'производительность')),
    ('2024-02-15', 1.0, (SELECT $node_id FROM Article WHERE id=5), (SELECT $node_id FROM Tag WHERE name=N'транзакции')),
    ('2024-03-01', 1.0, (SELECT $node_id FROM Article WHERE id=6), (SELECT $node_id FROM Tag WHERE name=N'NoSQL')),
    ('2024-03-01', 0.9, (SELECT $node_id FROM Article WHERE id=6), (SELECT $node_id FROM Tag WHERE name=N'графовые')),
    ('2024-03-10', 1.0, (SELECT $node_id FROM Article WHERE id=7), (SELECT $node_id FROM Tag WHERE name=N'графовые')),
    ('2024-03-15', 1.0, (SELECT $node_id FROM Article WHERE id=8), (SELECT $node_id FROM Tag WHERE name=N'PostgreSQL')),
    ('2024-03-15', 0.8, (SELECT $node_id FROM Article WHERE id=8), (SELECT $node_id FROM Tag WHERE name=N'реляционные')),
    ('2024-03-20', 1.0, (SELECT $node_id FROM Article WHERE id=9), (SELECT $node_id FROM Tag WHERE name=N'MongoDB')),
    ('2024-03-20', 0.9, (SELECT $node_id FROM Article WHERE id=9), (SELECT $node_id FROM Tag WHERE name=N'NoSQL'));
GO

INSERT INTO BelongsTo (main_category, $from_id, $to_id)
VALUES
    (1, (SELECT $node_id FROM Article WHERE id=1), (SELECT $node_id FROM Category WHERE name=N'Основы БД')),
    (1, (SELECT $node_id FROM Article WHERE id=2), (SELECT $node_id FROM Category WHERE name=N'Практика SQL')),
    (1, (SELECT $node_id FROM Article WHERE id=3), (SELECT $node_id FROM Category WHERE name=N'Теория БД')),
    (1, (SELECT $node_id FROM Article WHERE id=4), (SELECT $node_id FROM Category WHERE name=N'Оптимизация')),
    (1, (SELECT $node_id FROM Article WHERE id=5), (SELECT $node_id FROM Category WHERE name=N'Теория БД')),
    (1, (SELECT $node_id FROM Article WHERE id=6), (SELECT $node_id FROM Category WHERE name=N'NoSQL СУБД')),
    (1, (SELECT $node_id FROM Article WHERE id=7), (SELECT $node_id FROM Category WHERE name=N'NoSQL СУБД')),
    (1, (SELECT $node_id FROM Article WHERE id=8), (SELECT $node_id FROM Category WHERE name=N'Реляционные СУБД')),
    (1, (SELECT $node_id FROM Article WHERE id=9), (SELECT $node_id FROM Category WHERE name=N'NoSQL СУБД'));
GO

PRINT N'=== Запрос 1. Статьи, связанные с тегом "SQL" ===';
SELECT
    a.title,
    a.author,
    a.created_date,
    a.views,
    t.name
FROM Article AS a
   , Tagged   AS tg
   , Tag      AS t
WHERE MATCH(a-(tg)->t)
  AND t.name = N'SQL'
ORDER BY a.views DESC;
GO

PRINT N'=== Запрос 2. Статьи категории "Основы БД" с их дочерними категориями ===';
SELECT
    a.title,
    a.author,
    c.name,
    c.parent_category
FROM Article AS a
   , BelongsTo AS b
   , Category  AS c
WHERE MATCH(a-(b)->c)
  AND (c.name = N'Основы БД' OR c.parent_category = N'Основы БД')
ORDER BY c.name, a.title;
GO

PRINT N'=== Запрос 3. Статьи, связанные через ссылки ===';
SELECT
    a1.title,
    a1.author,
    a2.title,
    a2.author,
    r.reference_type,
    r.weight
FROM Article AS a1
   , [References] AS r
   , Article    AS a2
WHERE MATCH(a1-(r)->a2)
  AND a1.id <> a2.id
ORDER BY r.weight DESC, a1.title;
GO

PRINT N'=== Запрос 4. Популярные статьи по тегам ===';
SELECT
    t.name,
    COUNT(a.id),
    SUM(a.views),
    AVG(a.views)
FROM Tag AS t
   , Tagged AS tg
   , Article AS a
WHERE MATCH(t<-(tg)-a)
GROUP BY t.name
ORDER BY SUM(a.views) DESC;
GO

PRINT N'=== Запрос 5. Статьи, на которые чаще всего ссылаются (входящие ссылки) ===';
SELECT TOP 5
    a2.title,
    a2.author,
    COUNT(a2.title)
FROM Article AS a1
   , [References] AS r
   , Article AS a2
WHERE MATCH(a1-(r)->a2)
GROUP BY a2.title, a2.author, a2.$node_id
ORDER BY COUNT(a2.title) DESC;
GO

PRINT N'=== Запрос 6. Статьи с максимальным количеством исходящих ссылок ===';
SELECT TOP 5
    a1.title,
    a1.author,
    COUNT(a2.title)
FROM Article AS a1
   , [References] AS r
   , Article AS a2
WHERE MATCH(a1-(r)->a2)
GROUP BY a1.title, a1.author, a1.$node_id
ORDER BY COUNT(a2.title) DESC;
GO

PRINT N'=== Запрос 7. Статьи, имеющие ссылки на статьи с тегом "NoSQL" ===';
SELECT DISTINCT
    a1.title,
    a1.author
FROM Article AS a1
   , [References] AS r
   , Article    AS a2
   , Tagged     AS tg
   , Tag        AS t
WHERE MATCH(a1-(r)->a2-(tg)->t)
  AND t.name = N'NoSQL'
ORDER BY a1.title;
GO

PRINT N'=== Запрос 8. Самые популярные статьи в каждой категории ===';
WITH CategoryStats AS (
    SELECT 
        c.name AS CategoryName,
        c.$node_id AS CategoryNodeId,
        a.title AS ArticleTitle,
        a.views AS ArticleViews,
        a.author AS ArticleAuthor,
        ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY a.views DESC) AS rn
    FROM Category AS c
       , BelongsTo AS b
       , Article AS a
    WHERE MATCH(c<-(b)-a)
)
SELECT 
    CategoryName,
    ArticleTitle,
    ArticleAuthor,
    ArticleViews
FROM CategoryStats
WHERE rn = 1
ORDER BY CategoryName;
GO

PRINT N'=== Запрос 9. Связи между статьями через общие теги ===';
SELECT 
    a1.title,
    a2.title,
    COUNT(DISTINCT t.id)
FROM Article AS a1
   , Tagged AS tg1
   , Tag AS t
   , Tagged AS tg2
   , Article AS a2
WHERE MATCH(a1-(tg1)->t<-(tg2)-a2)
  AND a1.id < a2.id
GROUP BY a1.title, a2.title
ORDER BY COUNT(DISTINCT t.id) DESC;
GO

PRINT N'=== Запрос 10. Статистика связей между статьями для визуализации ===';
SELECT
    a1.id,
    a1.title,
    CONCAT(N'Article', a1.id),
    a2.id,
    a2.title,
    CONCAT(N'Article', a2.id),
    r.weight
FROM Article AS a1
   , [References] AS r
   , Article AS a2
WHERE MATCH(a1-(r)->a2);
GO