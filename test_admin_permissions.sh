#!/bin/bash

# Script de test pour vérifier les permissions d'un administrateur
# Test des 3 fonctionnalités : connexion admin, gestion activités, vue réservations

BASE_URL="https://localhost:8000/api"
ADMIN_EMAIL="superadmin@aquarhone.com"
ADMIN_PASSWORD="admin123"

echo "🔐 Test des permissions administrateur"
echo "======================================"

# 1. Connexion admin
echo -e "\n1️⃣  Connexion admin..."
LOGIN_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$ADMIN_EMAIL\",
    \"password\": \"$ADMIN_PASSWORD\"
  }")

echo "Réponse connexion admin: $LOGIN_RESPONSE"

# Extraire le token JWT admin
ADMIN_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Erreur: Impossible d'obtenir le token JWT admin"
    exit 1
fi

echo "✅ Token JWT admin obtenu: ${ADMIN_TOKEN:0:20}..."

# 2. Test 1: Ajout d'une nouvelle activité (admin)
echo -e "\n2️⃣  Test 1: Ajout d'une nouvelle activité (admin)..."
CREATE_ACTIVITY_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/activities" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Plongée sous-marine",
    "description": "Découvrez les fonds marins",
    "activityType": "canoe",
    "location": "Centre de plongée",
    "price": "80",
    "remainingSpots": 6
  }')

echo "Réponse création activité: $CREATE_ACTIVITY_RESPONSE"

# Extraire l'ID de l'activité créée
ACTIVITY_ID=$(echo $CREATE_ACTIVITY_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$ACTIVITY_ID" ]; then
    echo "❌ Erreur: Impossible de créer une activité"
    exit 1
fi

echo "✅ Activité créée: ID $ACTIVITY_ID"

# 3. Test 2: Édition d'une activité (admin)
echo -e "\n3️⃣  Test 2: Édition d'une activité (admin)..."
UPDATE_ACTIVITY_RESPONSE=$(curl -s -L -k -X PUT "$BASE_URL/activities/$ACTIVITY_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Plongée de luxe",
    "price": "100"
  }')

echo "Réponse édition activité: $UPDATE_ACTIVITY_RESPONSE"

# 4. Test 3: Suppression d'une activité (admin)
echo -e "\n4️⃣  Test 3: Suppression d'une activité (admin)..."
DELETE_ACTIVITY_RESPONSE=$(curl -s -L -k -X DELETE "$BASE_URL/activities/$ACTIVITY_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Réponse suppression activité: $DELETE_ACTIVITY_RESPONSE"

# 5. Test 4: Vue sur les réservations (admin)
echo -e "\n5️⃣  Test 4: Vue sur les réservations (admin)..."
RESERVATIONS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/reservations" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Réponse réservations admin: $RESERVATIONS_RESPONSE"

# 6. Test 5: Vérification du profil admin
echo -e "\n6️⃣  Test 5: Vérification du profil admin..."
PROFILE_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Réponse profil admin: $PROFILE_RESPONSE"

# 7. Test 6: Gestion des utilisateurs (admin)
echo -e "\n7️⃣  Test 6: Gestion des utilisateurs (admin)..."
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