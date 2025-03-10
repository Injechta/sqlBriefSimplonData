-- INSÉRER DES CLIENTS
INSERT INTO Client (code_client, nom, email) VALUES
('ab-001', 'Alice Dupont', 'alice.dupont@email.com'),
('cd-002', 'Bob Martin', 'bob.martin@email.com');

-- INSÉRER DES COMMANDES
INSERT INTO Commande (code_client, date_commande) VALUES
('ab-001', '2024-02-01'),
('cd-002', '2024-02-02');

-- INSÉRER DES MATIÈRES
INSERT INTO Matiere (nom, prix_m2) VALUES
('Plastique', 20.50),
('Bois', 35.75),
('Métal', 50.00);

-- INSÉRER DES COULEURS
INSERT INTO Couleur (nom, id_matiere) VALUES
('Rouge', 1),  -- Plastique
('Bleu', 1),   -- Plastique
('Marron', 2), -- Bois
('Gris', 3);   -- Métal

-- INSÉRER DES BOÎTES
INSERT INTO Boite (id_commande, id_matiere, id_couleur, longueur_mm, largeur_mm, hauteur_mm, quantite)
VALUES
(1, 1, 1, 500, 300, 200, 10),  -- Plastique Rouge
(1, 2, 3, 800, 500, 400, 5),   -- Bois Marron
(2, 3, 4, 1000, 700, 600, 2);  -- Métal Gris

SELECT * FROM Client;
SELECT * FROM Commande;
SELECT * FROM Matiere;
SELECT * FROM Couleur;
SELECT * FROM Boite;  -- Vérifier que prix_total est bien calculé

SELECT c.code_client, cmd.id_commande, b.id_boite, b.prix_total
FROM Client c
JOIN Commande cmd ON c.code_client = cmd.code_client
JOIN Boite b ON cmd.id_commande = b.id_commande;


UPDATE Boite
SET quantite = 15
WHERE id_boite = 1;

SELECT * FROM Boite WHERE id_boite = 1;


SELECT id_boite, longueur_mm, largeur_mm, hauteur_mm, quantite, prix_total
FROM Boite;

CREATE OR REPLACE VIEW rapport_commandes AS
SELECT 
    c.code_client,
    c.nom AS client_nom,
    cmd.id_commande,
    cmd.date_commande,
    SUM(b.prix_total) AS total_commande
FROM Client c
JOIN Commande cmd ON c.code_client = cmd.code_client
JOIN Boite b ON cmd.id_commande = b.id_commande
GROUP BY c.code_client, c.nom, cmd.id_commande, cmd.date_commande
ORDER BY cmd.date_commande DESC;

SELECT table_name
FROM information_schema.views
WHERE table_name = 'rapport_commandes';

SELECT id_boite, prix_total FROM Boite;

SELECT c.code_client, cmd.id_commande, b.id_boite, b.prix_total
FROM Client c
LEFT JOIN Commande cmd ON c.code_client = cmd.code_client
LEFT JOIN Boite b ON cmd.id_commande = b.id_commande;

SELECT * FROM rapport_commandes;

