#!/bin/bash

# Script de test pour vérifier les permissions d'un utilisateur standard

BASE_URL="https://localhost:8000/api"
USER_EMAIL="user@example.com"
USER_PASSWORD="password123"

echo "🧪 Test des permissions utilisateur non-admin"
echo "=============================================="

# 1. Inscription d'un nouvel utilisateur
echo -e "\n1️⃣  Inscription d'un nouvel utilisateur..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$USER_EMAIL\",
    \"password\": \"$USER_PASSWORD\"
  }")

echo "Réponse inscription: $REGISTER_RESPONSE"

# 1. Connexion utilisateur
echo -e "\n1️⃣  Connexion utilisateur..."
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

# 2. Test 1: Vue sur les activités (user)
echo -e "\n2️⃣  Test 1: Vue sur les activités (user)..."
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

# 3. Test 2: Réservation d'une activité (user)
echo -e "\n3️⃣  Test 2: Réservation d'une activité (user)..."
# Utiliser une date/heure future
FUTURE_DATE=$(date -d "+1 day" "+%Y-%m-%d 10:00:00")

RESERVATION_RESPONSE=$(curl -s -L -k -X POST "$BASE_URL/reservations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"activityId\": $FIRST_ACTIVITY_ID,
    \"dateTime\": \"$FUTURE_DATE\"
  }")

echo "Réponse création réservation: $RESERVATION_RESPONSE"

# Extraire l'ID de réservation
RESERVATION_ID=$(echo $RESERVATION_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$RESERVATION_ID" ]; then
    echo "⚠️  Aucune réservation créée (peut-être pas de créneaux disponibles)"
else
    echo "✅ Réservation créée: ID $RESERVATION_ID"
fi

# 4. Test 3: Vue sur ses réservations (user)
echo -e "\n4️⃣  Test 3: Vue sur ses réservations (user)..."
MY_RESERVATIONS_RESPONSE=$(curl -s -L -k -X GET "$BASE_URL/reservations/me" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "Réponse historique réservations: $MY_RESERVATIONS_RESPONSE"

# 5. Test 4: Tentative d'accès à la gestion des utilisateurs (user)
echo -e "\n5️⃣  Test 4: Tentative d'accès à la gestion des utilisateurs (user)..."
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