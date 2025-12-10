Enter password: *******
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 58
Server version: 8.4.6 MySQL Community Server - GPL

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> USE bibliotheque;
Database changed
mysql> SELECT COUNT(*) AS total_abonnes
    -> FROM abonne;
+---------------+
| total_abonnes |
+---------------+
|             2 |
+---------------+
1 row in set (0.00 sec)

mysql> SELECT AVG(nb) AS moyenne_emprunts
    -> FROM (
    ->   SELECT COUNT(*) AS nb
    ->   FROM emprunt
    ->   GROUP BY abonne_id
    -> ) AS sous;
+------------------+
| moyenne_emprunts |
+------------------+
|           1.5000 |
+------------------+
1 row in set (0.00 sec)

mysql> SELECT AVG(prix_unitaire) AS prix_moyen
    -> FROM ouvrage;
ERROR 1054 (42S22): Unknown column 'prix_unitaire' in 'field list'
mysql> ALTER TABLE ouvrage ADD COLUMN prix_unitaire DECIMAL(10,2) DEFAULT 100.00;
Query OK, 0 rows affected (0.18 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> SELECT AVG(prix_unitaire) AS prix_moyen FROM ouvrage;
+------------+
| prix_moyen |
+------------+
| 100.000000 |
+------------+
1 row in set (0.00 sec)

mysql> SELECT abonne_id, COUNT(*) AS nbre
    -> FROM emprunt
    -> GROUP BY abonne_id;
+-----------+------+
| abonne_id | nbre |
+-----------+------+
|         1 |    2 |
|         5 |    1 |
+-----------+------+
2 rows in set (0.00 sec)

mysql> SELECT auteur_id, COUNT(*) AS total_ouvrages
    -> FROM ouvrage
    -> GROUP BY auteur_id;
+-----------+----------------+
| auteur_id | total_ouvrages |
+-----------+----------------+
|         1 |              2 |
|         2 |              2 |
|         3 |              2 |
+-----------+----------------+
3 rows in set (0.00 sec)

mysql> SELECT abonne_id, COUNT(*) AS nbre
    -> FROM emprunt
    -> GROUP BY abonne_id
    -> HAVING COUNT(*) >= 3;
Empty set (0.00 sec)

mysql> SELECT auteur_id, COUNT(*) AS total_ouvrages
    -> FROM ouvrage
    -> GROUP BY auteur_id
    -> HAVING total_ouvrages > 5;
Empty set (0.00 sec)

mysql> SELECT a.nom, COUNT(e.id) AS emprunts
    -> FROM abonne a
    -> LEFT JOIN emprunt e ON e.abonne_id = a.id
    -> GROUP BY a.id, a.nom;
+-------+----------+
| nom   | emprunts |
+-------+----------+
| Karim |        2 |
| Samir |        1 |
+-------+----------+
2 rows in set (0.00 sec)

mysql> SELECT au.nom, COUNT(e.id) AS total_emprunts
    -> FROM auteur au
    -> JOIN ouvrage o ON o.auteur_id = au.id
    -> LEFT JOIN emprunt e ON e.ouvrage_id = o.id
    -> GROUP BY au.id, au.nom;
+---------------+----------------+
| nom           | total_emprunts |
+---------------+----------------+
| Victor Hugo   |              0 |
| George Orwell |              2 |
| Jane Austen   |              1 |
+---------------+----------------+
3 rows in set (0.00 sec)

mysql> SELECT
    ->   ROUND(
    ->     COUNT(CASE WHEN e.id IS NOT NULL THEN 1 END) * 100
    ->     / COUNT(DISTINCT o.id), 2
    ->   ) AS pct_empruntes
    -> FROM ouvrage o
    -> LEFT JOIN emprunt e ON e.ouvrage_id = o.id;
+---------------+
| pct_empruntes |
+---------------+
|         50.00 |
+---------------+
1 row in set (0.00 sec)

mysql> SELECT a.nom, COUNT(*) AS nbre_emprunts
    -> FROM abonne a
    -> JOIN emprunt e ON e.abonne_id = a.id
    -> GROUP BY a.id, a.nom
    -> ORDER BY nbre_emprunts DESC
    -> LIMIT 3;
+-------+---------------+
| nom   | nbre_emprunts |
+-------+---------------+
| Karim |             2 |
| Samir |             1 |
+-------+---------------+
2 rows in set (0.00 sec)

mysql> WITH stats AS (
    ->   SELECT o.auteur_id, COUNT(e.id) AS emprunts, COUNT(DISTINCT o.id) AS ouvrages
    ->   FROM ouvrage o
    ->   LEFT JOIN emprunt e ON e.ouvrage_id = o.id
    ->   GROUP BY o.auteur_id
    -> )
    -> SELECT s.auteur_id, s.emprunts / s.ouvrages AS moyenne
    -> FROM stats s
    -> WHERE s.emprunts / s.ouvrages > 2;
Empty set (0.00 sec)

mysql> CREATE INDEX idx_abonne_perf ON emprunt(abonne_id);
Query OK, 0 rows affected (0.08 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> EXPLAIN SELECT abonne_id, COUNT(*)
    -> FROM emprunt
    -> GROUP BY abonne_id;
+----+-------------+---------+------------+-------+-----------------+-----------------+---------+------+------+----------+-------------+
| id | select_type | table   | partitions | type  | possible_keys   | key             | key_len | ref  | rows | filtered | Extra       |
+----+-------------+---------+------------+-------+-----------------+-----------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | emprunt | NULL       | index | idx_abonne_perf | idx_abonne_perf | 4       | NULL |    2 |   100.00 | Using index |
+----+-------------+---------+------------+-------+-----------------+-----------------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.01 sec)

mysql> SELECT DAYNAME(date_debut) AS jour_semaine, COUNT(*) AS nbre_emprunts
    -> FROM emprunt
    -> GROUP BY DAYNAME(date_debut);
+--------------+---------------+
| jour_semaine | nbre_emprunts |
+--------------+---------------+
| Wednesday    |             2 |
| Thursday     |             1 |
+--------------+---------------+
2 rows in set (0.01 sec)

mysql> SELECT MONTHNAME(date_debut) AS mois, COUNT(*) AS total_emprunts
    -> FROM emprunt
    -> WHERE YEAR(date_debut) = 2025
    -> GROUP BY MONTHNAME(date_debut);
+------+----------------+
| mois | total_emprunts |
+------+----------------+
| June |              3 |
+------+----------------+
1 row in set (0.00 sec)

mysql> SELECT COUNT(*) AS ouvrages_jamais_empruntes
    -> FROM ouvrage o
    -> LEFT JOIN emprunt e ON o.id = e.ouvrage_id
    -> WHERE e.id IS NULL;
+---------------------------+
| ouvrages_jamais_empruntes |
+---------------------------+
|                         4 |
+---------------------------+
1 row in set (0.01 sec)

mysql>