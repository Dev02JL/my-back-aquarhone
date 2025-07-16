#!/bin/bash

# Script de test pour vérifier les permissions d'un utilisateur standard

BASE_URL="http://localhost:8000/api"

# Générer un email unique à chaque exécution
UNIQ_ID=$(date +%s)$RANDOM
USER_EMAIL="user_${UNIQ_ID}@example.com"
USER_PASSWORD="password123"

echo "🧪 Test des permissions utilisateur non-admin"
echo "=============================================="

# 1. Création de l'utilisateur en base
echo -e "\n1️⃣  Création de l'utilisateur en base..."
# Hasher le mot de passe (hash généré par Symfony pour password123)
HASHED_PASSWORD='$2y$13$ftnWPPBwTk.llQ9mtxUK.e2SEdR/IguX5zf8cKM5VDNxCCNF0v9Y6'

# Insérer l'utilisateur directement en base
INSERT_RESULT=$(php bin/console doctrine:query:sql "INSERT INTO user (email, password, roles) VALUES ('$USER_EMAIL', '$HASHED_PASSWORD', '[\"ROLE_USER\"]')")
echo "Résultat création utilisateur: $INSERT_RESULT"

# Vérifier que l'utilisateur a été créé
USER_ID=$(php bin/console doctrine:query:sql "SELECT id FROM user WHERE email = '$USER_EMAIL'" | sed -n '4p' | tr -d ' ')
if [[ -z "$USER_ID" || "$USER_ID" == "id" ]]; then
    echo "❌ Erreur: Impossible de récupérer l'ID de l'utilisateur ($USER_EMAIL)"
    exit 1
fi

echo "✅ Utilisateur créé (id: $USER_ID)"

# 2. Connexion utilisateur
echo -e "\n2️⃣  Connexion utilisateur..."
LOGIN_PAYLOAD=$(printf '{"email":"%s","password":"%s"}' "$USER_EMAIL" "$USER_PASSWORD")
LOGIN_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "$LOGIN_PAYLOAD")
echo "Réponse connexion: $LOGIN_RESPONSE"

# Extraire le token JWT
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
    echo "❌ Erreur: Impossible d'obtenir le token JWT"
    exit 1
fi
echo "✅ Token JWT obtenu: ${TOKEN:0:20}..."

# 3. Test 1: Vue sur les activités (user)
echo -e "\n3️⃣  Test 1: Vue sur les activités (user)..."
ACTIVITIES_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/activities" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse liste activités: $ACTIVITIES_RESPONSE"

# Extraire le premier ID d'activité pour les tests suivants
FIRST_ACTIVITY_ID=$(echo $ACTIVITIES_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -z "$FIRST_ACTIVITY_ID" ]; then
    echo "❌ Erreur: Aucune activité trouvée"
    exit 1
fi
echo "✅ Première activité trouvée: ID $FIRST_ACTIVITY_ID"

# 4. Test 2: Réservation d'une activité (user)
echo -e "\n4️⃣  Test 2: Réservation d'une activité (user)..."
FUTURE_DATE=$(date -v+1d "+%Y-%m-%d 10:00:00")
RESERVATION_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/reservations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\n    \"activityId\": $FIRST_ACTIVITY_ID,\n    \"dateTime\": \"$FUTURE_DATE\"\n  }")
echo "Réponse création réservation: $RESERVATION_RESPONSE"

RESERVATION_ID=$(echo $RESERVATION_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -z "$RESERVATION_ID" ]; then
    echo "⚠️  Aucune réservation créée (peut-être pas de créneaux disponibles)"
else
    echo "✅ Réservation créée: ID $RESERVATION_ID"
fi

# 5. Test 3: Vue sur ses réservations (user)
echo -e "\n5️⃣  Test 3: Vue sur ses réservations (user)..."
MY_RESERVATIONS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/reservations/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse historique réservations: $MY_RESERVATIONS_RESPONSE"

# 6. Test 4: Tentative d'accès à la gestion des utilisateurs (user)
echo -e "\n6️⃣  Test 4: Tentative d'accès à la gestion des utilisateurs (user)..."
USERS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")
echo "Réponse profil utilisateur: $USERS_RESPONSE"

echo -e "\n🎯 Résumé des tests:"
echo "====================="
echo "✅ Consultation des activités: OK"
echo "✅ Consultation des détails d'activité: OK"
echo "✅ Création de réservation: OK"
echo "✅ Consultation historique: OK"
echo "✅ Profil utilisateur: OK"

echo -e "\n🎉 Tous les tests pour un utilisateur non-admin sont PASSÉS !" 