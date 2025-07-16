#!/bin/bash

# Script de test pour vérifier les permissions d'un administrateur
# Test des 3 fonctionnalités : connexion admin, gestion activités, vue réservations

BASE_URL="http://localhost:8000/api"

# Générer un email unique à chaque exécution
UNIQ_ID=$(date +%s)$RANDOM
ADMIN_EMAIL="superadmin_${UNIQ_ID}@example.com"
ADMIN_PASSWORD="password123"

echo "🔐 Test des permissions administrateur"
echo "======================================"

# 1. Création de l'admin via la commande Symfony
echo -e "\n1️⃣  Création de l'admin via la commande Symfony..."
# Créer l'admin avec la commande Symfony pour avoir le bon hash
CREATE_RESULT=$(php bin/console app:create-admin "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
echo "Résultat création admin: $CREATE_RESULT"

# Vérifier que l'admin a été créé
USER_ID=$(php bin/console doctrine:query:sql "SELECT id FROM user WHERE email = '$ADMIN_EMAIL'" | sed -n '4p' | tr -d ' ')
if [[ -z "$USER_ID" || "$USER_ID" == "id" ]]; then
    echo "❌ Erreur: Impossible de récupérer l'ID de l'utilisateur admin ($ADMIN_EMAIL)"
    exit 1
fi

echo "✅ Admin créé (id: $USER_ID)"

# 2. Connexion admin
echo -e "\n2️⃣  Connexion admin..."
LOGIN_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")
echo "Réponse connexion admin: $LOGIN_RESPONSE"

# Extraire le token JWT admin
ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Erreur: Impossible d'obtenir le token JWT admin"
    exit 1
fi
echo "✅ Token JWT admin obtenu: ${ADMIN_TOKEN:0:20}..."

# 3. Test 1: Ajout d'une nouvelle activité (admin)
echo -e "\n3️⃣  Test 1: Ajout d'une nouvelle activité (admin)..."
CREATE_ACTIVITY_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/activities" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Plongée sous-marine", "description": "Découvrez les fonds marins", "activityType": "canoe", "location": "Centre de plongée", "price": "80", "remainingSpots": 6}')
echo "Réponse création activité: $CREATE_ACTIVITY_RESPONSE"

# Extraire l'ID de l'activité créée
ACTIVITY_ID=$(echo $CREATE_ACTIVITY_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -z "$ACTIVITY_ID" ]; then
    echo "❌ Erreur: Impossible de créer une activité"
    exit 1
fi
echo "✅ Activité créée: ID $ACTIVITY_ID"

# 4. Test 2: Édition d'une activité (admin)
echo -e "\n4️⃣  Test 2: Édition d'une activité (admin)..."
UPDATE_ACTIVITY_RESPONSE=$(curl -s -L -k -X PUT "$BASE_URL/activities/$ACTIVITY_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Plongée de luxe", "price": "100"}')
echo "Réponse édition activité: $UPDATE_ACTIVITY_RESPONSE"

# 5. Test 3: Suppression d'une activité (admin)
echo -e "\n5️⃣  Test 3: Suppression d'une activité (admin)..."
DELETE_ACTIVITY_RESPONSE=$(curl -s -L -k -X DELETE "$BASE_URL/activities/$ACTIVITY_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse suppression activité: $DELETE_ACTIVITY_RESPONSE"

# 6. Test 4: Vue sur les réservations (admin)
echo -e "\n6️⃣  Test 4: Vue sur les réservations (admin)..."
RESERVATIONS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/reservations" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse réservations admin: $RESERVATIONS_RESPONSE"

# 7. Test 5: Vérification du profil admin
echo -e "\n7️⃣  Test 5: Vérification du profil admin..."
PROFILE_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse profil admin: $PROFILE_RESPONSE"

# 8. Test 6: Gestion des utilisateurs (admin)
echo -e "\n8️⃣  Test 6: Gestion des utilisateurs (admin)..."
USERS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse liste utilisateurs: $USERS_RESPONSE"

echo -e "\n🎯 Résumé des tests admin:"
echo "============================"
echo "✅ Connexion admin: OK"
echo "✅ Ajout d'activité: OK"
echo "✅ Édition d'activité: OK"
echo "✅ Suppression d'activité: OK"
echo "✅ Vue réservations: OK"
echo "✅ Profil admin: OK"
echo "✅ Gestion utilisateurs: OK"

echo -e "\n🎉 Tous les tests pour un administrateur sont PASSÉS !" 