-- TABLE CLIENT
CREATE TABLE Client (
    code_client VARCHAR(6) PRIMARY KEY CHECK (code_client ~ '^[a-z]{2}-[0-9]{3}$'), -- Format xx-123
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- TABLE COMMANDE
CREATE TABLE Commande (
    id_commande SERIAL PRIMARY KEY,
    code_client VARCHAR(6) NOT NULL,
    date_commande DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (code_client) REFERENCES Client(code_client) ON DELETE CASCADE
);

-- TABLE MATIERE
CREATE TABLE Matiere (
    id_matiere SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL,
    prix_m2 DECIMAL(15,2) NOT NULL CHECK (prix_m2 > 0)
);

-- TABLE COULEUR
CREATE TABLE Couleur (
    id_couleur SERIAL PRIMARY KEY,
    nom VARCHAR(50) UNIQUE NOT NULL,
    id_matiere INTEGER NOT NULL,
    FOREIGN KEY (id_matiere) REFERENCES Matiere(id_matiere) ON DELETE CASCADE
);

-- TABLE BOITE
CREATE TABLE Boite (
    id_boite SERIAL PRIMARY KEY,
    id_commande INTEGER NOT NULL,
    id_matiere INTEGER NOT NULL,
    id_couleur INTEGER NOT NULL,
    longueur_mm INTEGER NOT NULL CHECK (longueur_mm BETWEEN 1 AND 1000),
    largeur_mm INTEGER NOT NULL CHECK (largeur_mm BETWEEN 1 AND 1000),
    hauteur_mm INTEGER NOT NULL CHECK (hauteur_mm BETWEEN 1 AND 1000),
    quantite INTEGER NOT NULL CHECK (quantite > 0),
    prix_total DECIMAL(15,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (id_commande) REFERENCES Commande(id_commande) ON DELETE CASCADE,
    FOREIGN KEY (id_matiere) REFERENCES Matiere(id_matiere) ON DELETE CASCADE,
    FOREIGN KEY (id_couleur) REFERENCES Couleur(id_couleur) ON DELETE CASCADE
);

-- Supprimer l'ancienne fonction si elle existe
DROP FUNCTION IF EXISTS calculer_prix_total;

-- Créer la nouvelle fonction
CREATE OR REPLACE FUNCTION calculer_prix_total()
RETURNS TRIGGER AS $$
DECLARE
    prix_unitaire DECIMAL(15,2);
    surface_m2 DECIMAL(15,6);
    reduction DECIMAL(5,2) := 0;
BEGIN
    -- Convertir la surface de mm² en m²
    surface_m2 := (2 * (NEW.longueur_mm * NEW.largeur_mm + 
                        NEW.longueur_mm * NEW.hauteur_mm + 
                        NEW.largeur_mm * NEW.hauteur_mm)) / 1000000.0;

    -- Récupérer le prix au m² de la matière
    SELECT prix_m2 INTO prix_unitaire 
    FROM Matiere WHERE id_matiere = NEW.id_matiere;

    -- Appliquer la réduction en fonction des quantités
    IF NEW.quantite BETWEEN 6 AND 10 THEN
        reduction := 0.05;  -- 5% de réduction
    ELSIF NEW.quantite BETWEEN 11 AND 20 THEN
        reduction := 0.10;  -- 10% de réduction
    ELSIF NEW.quantite > 20 THEN
        reduction := 0.15;  -- 15% de réduction
    END IF;

    -- Calcul du prix total
    NEW.prix_total := surface_m2 * prix_unitaire * NEW.quantite * (1 - reduction);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Supprimer l'ancien trigger s'il existe
DROP TRIGGER IF EXISTS trigger_calcul_prix ON Boite;

-- Créer le trigger pour appliquer la réduction automatiquement
CREATE TRIGGER trigger_calcul_prix
BEFORE INSERT OR UPDATE ON Boite
FOR EACH ROW EXECUTE FUNCTION calculer_prix_total();