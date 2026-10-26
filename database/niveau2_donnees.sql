-- Données de démonstration du niveau 2.
INSERT INTO serveur (nom, telephone, actif) VALUES
    ('Tiana', '0341111111', TRUE),
    ('Haja',  '0342222222', TRUE),
    ('Fara',  '0343333333', TRUE),
    ('Solo',  '0344444444', FALSE);

-- Les commandes historiques deviennent payées pour libérer leurs tables.
UPDATE commande
SET statut = 'payee', mode_paiement = 'especes', date_paiement = date_commande
WHERE EXISTS (
    SELECT 1 FROM serveur s
    WHERE s.id = commande.id_serveur AND s.nom = 'Bao (historique)'
);

DO $$
DECLARE
    i INTEGER;
    new_id INTEGER;
    chosen_server INTEGER;
    chosen_status VARCHAR(20);
    chosen_table INTEGER;
    payment VARCHAR(30);
    chosen_date TIMESTAMP(0);
    dish_id INTEGER;
BEGIN
    FOR i IN 1..20 LOOP
        SELECT id INTO chosen_server FROM serveur
        WHERE nom IN ('Tiana', 'Haja', 'Fara')
        ORDER BY random() LIMIT 1;

        chosen_status := CASE
            WHEN i = 1 THEN 'en_cours'
            WHEN i = 2 THEN 'servie'
            WHEN i % 4 = 0 THEN 'annulee'
            ELSE 'payee'
        END;
        chosen_table := CASE WHEN i = 1 THEN 2 WHEN i = 2 THEN 4 ELSE 1 + ((i * 7) % 12) END;
        -- Évite les tables des deux commandes ouvertes historiques.
        IF chosen_status IN ('en_cours', 'servie') AND chosen_table IN (1, 3) THEN
            chosen_table := 5;
        END IF;
        chosen_date := (CURRENT_DATE - ((i - 1) % 3)) + TIME '11:00'
                       + random() * INTERVAL '3 hours';
        payment := CASE WHEN chosen_status = 'payee'
            THEN (ARRAY['especes','mvola','orange_money','airtel_money'])[1 + floor(random() * 4)::int]
            ELSE NULL END;

        INSERT INTO commande (date_commande, numero_table, id_serveur, statut, mode_paiement, date_paiement)
        VALUES (chosen_date, chosen_table, chosen_server, chosen_status, payment,
                CASE WHEN chosen_status = 'payee' THEN chosen_date + INTERVAL '30 minutes' ELSE NULL END)
        RETURNING id INTO new_id;

        FOR dish_id IN
            SELECT id FROM plat ORDER BY random() LIMIT (1 + floor(random() * 4)::int)
        LOOP
            INSERT INTO commande_ligne (id_commande, id_plat, quantite, prix_unitaire)
            SELECT new_id, p.id, 1 + floor(random() * 3)::int, p.prix
            FROM plat p WHERE p.id = dish_id;
        END LOOP;
    END LOOP;
END $$;
