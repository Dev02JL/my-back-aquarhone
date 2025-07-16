#!/bin/bash

# Script pour remplir le jeu de données (JDD) avec des données de test
# Ce script doit être exécuté avant les tests pour s'assurer que les données nécessaires existent

echo "🗄️  Remplissage du jeu de données (JDD)"
echo "========================================"

# 1. Création des utilisateurs de test
echo -e "\n1️⃣  Création des utilisateurs de test..."

# Créer l'administrateur principal
php bin/console app:create-admin superadmin@aquarhone.com admin123

# Créer des utilisateurs standards
php bin/console doctrine:query:sql "INSERT OR IGNORE INTO user (email, password, roles) VALUES 
('test@example.com', '\$2y\$13\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '[\"ROLE_USER\"]'),
('user@example.com', '\$2y\$13\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '[\"ROLE_USER\"]'),
('user2@example.com', '\$2y\$13\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '[\"ROLE_USER\"]'),
('admin@example.com', '\$2y\$13\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '[\"ROLE_USER\"]')"

echo "✅ Utilisateurs créés"

# 2. Création des activités de test
echo -e "\n2️⃣  Création des activités de test..."

# Supprimer les activités existantes pour éviter les doublons
php bin/console doctrine:query:sql "DELETE FROM activity"

# Créer les activités de test avec créneaux horaires
php bin/console doctrine:query:sql "INSERT INTO activity (name, description, activity_type, location, available_slots, price, remaining_spots, created_at, updated_at) VALUES 
('Kayak en mer', 'Découvrez la côte en kayak de mer', 'kayak', 'Port de plaisance', '[\"2024-07-20 09:00:00\", \"2024-07-20 10:30:00\", \"2024-07-20 14:00:00\", \"2024-07-20 15:30:00\", \"2024-07-21 09:00:00\", \"2024-07-21 10:30:00\", \"2024-07-21 14:00:00\", \"2024-07-21 15:30:00\", \"2024-07-22 09:00:00\", \"2024-07-22 10:30:00\", \"2024-07-22 14:00:00\", \"2024-07-22 15:30:00\"]', 45.00, 8, datetime('now'), datetime('now')),
('Paddle en mer', 'Balade en paddle sur la Méditerranée', 'paddle', 'Plage de la Corniche', '[\"2024-07-20 10:00:00\", \"2024-07-20 11:30:00\", \"2024-07-20 15:00:00\", \"2024-07-20 16:30:00\", \"2024-07-21 10:00:00\", \"2024-07-21 11:30:00\", \"2024-07-21 15:00:00\", \"2024-07-21 16:30:00\", \"2024-07-22 10:00:00\", \"2024-07-22 11:30:00\", \"2024-07-22 15:00:00\", \"2024-07-22 16:30:00\"]', 35.00, 6, datetime('now'), datetime('now')),
('Plongée sous-marine', 'Exploration des fonds marins', 'diving', 'Centre de plongée', '[\"2024-07-20 08:00:00\", \"2024-07-20 10:00:00\", \"2024-07-20 14:00:00\", \"2024-07-20 16:00:00\", \"2024-07-21 08:00:00\", \"2024-07-21 10:00:00\", \"2024-07-21 14:00:00\", \"2024-07-21 16:00:00\", \"2024-07-22 08:00:00\", \"2024-07-22 10:00:00\", \"2024-07-22 14:00:00\", \"2024-07-22 16:00:00\"]', 80.00, 4, datetime('now'), datetime('now')),
('Voile légère', 'Initiation à la voile sur optimist', 'sailing', 'Club nautique', '[\"2024-07-20 09:30:00\", \"2024-07-20 11:00:00\", \"2024-07-20 14:30:00\", \"2024-07-20 16:00:00\", \"2024-07-21 09:30:00\", \"2024-07-21 11:00:00\", \"2024-07-21 14:30:00\", \"2024-07-21 16:00:00\", \"2024-07-22 09:30:00\", \"2024-07-22 11:00:00\", \"2024-07-22 14:30:00\", \"2024-07-22 16:00:00\"]', 60.00, 10, datetime('now'), datetime('now')),
('Jet ski', 'Sensation forte en jet ski', 'jetski', 'Base nautique', '[\"2024-07-20 10:00:00\", \"2024-07-20 11:30:00\", \"2024-07-20 15:00:00\", \"2024-07-20 16:30:00\", \"2024-07-21 10:00:00\", \"2024-07-21 11:30:00\", \"2024-07-21 15:00:00\", \"2024-07-21 16:30:00\", \"2024-07-22 10:00:00\", \"2024-07-22 11:30:00\", \"2024-07-22 15:00:00\", \"2024-07-22 16:30:00\"]', 120.00, 2, datetime('now'), datetime('now'))"

echo "✅ Activités créées"

# 3. Création de quelques réservations de test
echo -e "\n3️⃣  Création de réservations de test..."

# Supprimer les réservations existantes
php bin/console doctrine:query:sql "DELETE FROM reservation"

# Créer quelques réservations de test
php bin/console doctrine:query:sql "INSERT INTO reservation (user_id, activity_id, date_time, status, created_at, updated_at) VALUES 
(2, 1, datetime('now', '+1 day'), 'confirmed', datetime('now'), datetime('now')),
(3, 2, datetime('now', '+2 days'), 'confirmed', datetime('now'), datetime('now')),
(4, 3, datetime('now', '+3 days'), 'pending', datetime('now'), datetime('now'))"

echo "✅ Réservations créées"

# 4. Vérification des données
echo -e "\n4️⃣  Vérification des données créées..."

echo "📊 Statistiques du JDD :"
echo "========================"

# Compter les utilisateurs
USER_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM user" | tail -1 | tr -d ' ')
echo "👥 Utilisateurs : $USER_COUNT"

# Compter les activités
ACTIVITY_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM activity" | tail -1 | tr -d ' ')
echo "🏄 Activités : $ACTIVITY_COUNT"

# Compter les réservations
RESERVATION_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM reservation" | tail -1 | tr -d ' ')
echo "📅 Réservations : $RESERVATION_COUNT"

echo -e "\n📋 Liste des utilisateurs :"
php bin/console doctrine:query:sql "SELECT email, roles FROM user"

echo -e "\n📋 Liste des activités :"
php bin/console doctrine:query:sql "SELECT name, activity_type, location, price FROM activity"

echo -e "\n🎉 JDD rempli avec succès !"
echo "Les tests peuvent maintenant être exécutés." 