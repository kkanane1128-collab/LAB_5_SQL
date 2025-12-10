mysql> USE bibloitheque;
ERROR 1049 (42000): Unknown database 'bibloitheque'
mysql> USE bibliotheque;
Database changed
mysql> WITH RECURSIVE
    -> mois_ref AS (
    ->     SELECT 1 AS mois
    ->     UNION ALL
    ->     SELECT mois + 1 FROM mois_ref WHERE mois < 12
    -> ),
    -> ref_total_ouvrages AS (
    ->     SELECT COUNT(*) AS total_global FROM ouvrage
    -> ),
    -> stats_mensuelles AS (
    ->     SELECT
    ->       MONTH(date_debut) AS mois,
    ->       COUNT(*) AS total_emprunts,
    ->       COUNT(DISTINCT abonne_id) AS abonnes_actifs,
    ->       ROUND(COUNT(*) / COUNT(DISTINCT abonne_id), 2) AS moyenne_par_abonne,
    ->       COUNT(DISTINCT ouvrage_id) AS nb_ouvrages_distincts_empruntes
    ->     FROM emprunt
    ->     WHERE YEAR(date_debut) = 2025
    ->     GROUP BY MONTH(date_debut)
    -> ),
    -> detail_classement AS (
    ->     SELECT
    ->       MONTH(date_debut) AS mois,
    ->       ouvrage_id,
    ->       COUNT(*) AS nb_emprunts,
    ->       ROW_NUMBER() OVER (PARTITION BY MONTH(date_debut) ORDER BY COUNT(*) DESC) AS rang
    ->     FROM emprunt
    ->     WHERE YEAR(date_debut) = 2025
    ->     GROUP BY MONTH(date_debut), ouvrage_id
    -> ),
    -> top_3_formatted AS (
    ->     SELECT
    ->       d.mois,
    ->       GROUP_CONCAT(o.titre ORDER BY d.rang SEPARATOR ', ') AS top_livres
    ->     FROM detail_classement d
    ->     JOIN ouvrage o ON d.ouvrage_id = o.id
    ->     WHERE d.rang <= 3
    ->     GROUP BY d.mois
    -> )
    -> SELECT
    ->   CONCAT('2025-', LPAD(m.mois, 2, '0')) AS annee_mois,
    ->   COALESCE(s.total_emprunts, 0) AS total_emprunts,
    ->   COALESCE(s.abonnes_actifs, 0) AS abonnes_actifs,
    ->   COALESCE(s.moyenne_par_abonne, 0.00) AS moyenne_par_abonne,
    ->   COALESCE(t.top_livres, 'Aucun emprunt') AS top_3_ouvrages,
    ->   COALESCE(ROUND((s.nb_ouvrages_distincts_empruntes * 100.0) / r.total_global, 2), 0.00) AS pct_ouvrages_empruntes
    -> FROM mois_ref m
    -> CROSS JOIN ref_total_ouvrages r
    -> LEFT JOIN stats_mensuelles s ON m.mois = s.mois
    -> LEFT JOIN top_3_formatted t ON m.mois = t.mois
    -> ORDER BY m.mois;
+------------+----------------+----------------+--------------------+---------------------------+------------------------+
| annee_mois | total_emprunts | abonnes_actifs | moyenne_par_abonne | top_3_ouvrages            | pct_ouvrages_empruntes |
+------------+----------------+----------------+--------------------+---------------------------+------------------------+
| 2025-01    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-02    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-03    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-04    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-05    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-06    |              3 |              2 |               1.50 | 1984, Pride and Prejudice |                  33.33 |
| 2025-07    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-08    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-09    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-10    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-11    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
| 2025-12    |              0 |              0 |               0.00 | Aucun emprunt             |                   0.00 |
+------------+----------------+----------------+--------------------+---------------------------+------------------------+
12 rows in set (0.01 sec)
