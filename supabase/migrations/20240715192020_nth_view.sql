CREATE OR REPLACE VIEW numbered_blocks AS
SELECT
    b.id AS block_id,
    b.start,
    b."end",
    b.subtitle,
    b.owner,
    b.created_at,
    ROW_NUMBER() OVER (PARTITION BY b.owner ORDER BY b.start) AS index,
    COUNT(*) OVER (PARTITION BY b.owner) AS total
FROM
    blocks b;
