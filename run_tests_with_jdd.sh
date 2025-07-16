#!/bin/bash

# Script principal pour nettoyer, remplir le JDD et exécuter tous les tests
# Ce script garantit que les tests fonctionnent avec un JDD propre et reproductible

echo "🚀 Script de test complet avec JDD"
echo "=================================="

# Rendre les scripts exécutables
chmod +x clean_db.sh fill_jdd.sh test_admin_permissions.sh test_user_permissions.sh

# 1. Nettoyer la base de données
echo -e "\n1️⃣  Nettoyage de la base de données..."
./clean_db.sh --force

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du nettoyage de la base de données"
    exit 1
fi

# 2. Remplir le JDD
echo -e "\n2️⃣  Remplissage du JDD..."
./fill_jdd.sh

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du remplissage du JDD"
    exit 1
fi

# 3. Attendre que le serveur soit prêt
echo -e "\n3️⃣  Vérification que le serveur est prêt..."
sleep 3

# 4. Lancer les tests admin
echo -e "\n4️⃣  Lancement des tests administrateur..."
./test_admin_permissions.sh

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors des tests administrateur"
    exit 1
fi

# 5. Lancer les tests utilisateur
echo -e "\n5️⃣  Lancement des tests utilisateur..."
./test_user_permissions.sh

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors des tests utilisateur"
    exit 1
fi

echo -e "\n🎉 Tous les tests sont PASSÉS avec succès !"
echo "=============================================="
echo "✅ Base de données nettoyée"
echo "✅ JDD rempli"
echo "✅ Tests administrateur : PASSÉS"
echo "✅ Tests utilisateur : PASSÉS"
echo ""
echo "🎯 Le système fonctionne parfaitement avec un JDD propre et reproductible !" 