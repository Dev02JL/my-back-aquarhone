#!/bin/bash

# Script pour nettoyer complètement la base de données
# ATTENTION : Ce script supprime TOUTES les données !

echo "🧹 Nettoyage de la base de données"
echo "=================================="

# Vérifier si on est en mode non-interactif
if [[ "$1" == "--force" ]]; then
    echo "⚠️  Mode non-interactif activé"
    CONFIRM="y"
else
    # Demander confirmation
    read -p "⚠️  ATTENTION : Ce script va supprimer TOUTES les données. Continuer ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Nettoyage annulé"
        exit 1
    fi
    CONFIRM="y"
fi

if [[ "$CONFIRM" == "y" ]]; then
    echo -e "\n🗑️  Suppression de toutes les données..."

    # Supprimer les réservations
    php bin/console doctrine:query:sql "DELETE FROM reservation"
    echo "✅ Réservations supprimées"

    # Supprimer les activités
    php bin/console doctrine:query:sql "DELETE FROM activity"
    echo "✅ Activités supprimées"

    # Supprimer les utilisateurs (sauf l'admin principal)
    php bin/console doctrine:query:sql "DELETE FROM user WHERE email != 'superadmin@aquarhone.com'"
    echo "✅ Utilisateurs supprimés (sauf admin principal)"

    # Vérifier l'état de la base
    echo -e "\n📊 État de la base après nettoyage :"
    echo "========================================"

    USER_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM user" | grep -E '^\s*[0-9]+\s*$' | tr -d ' ')
ACTIVITY_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM activity" | grep -E '^\s*[0-9]+\s*$' | tr -d ' ')
RESERVATION_COUNT=$(php bin/console doctrine:query:sql "SELECT COUNT(*) as count FROM reservation" | grep -E '^\s*[0-9]+\s*$' | tr -d ' ')

    echo "👥 Utilisateurs : $USER_COUNT"
    echo "🏄 Activités : $ACTIVITY_COUNT"
    echo "📅 Réservations : $RESERVATION_COUNT"

    echo -e "\n🎉 Base de données nettoyée avec succès !"
    echo "Vous pouvez maintenant exécuter fill_jdd.sh pour remplir le JDD."
else
    echo "❌ Nettoyage annulé"
    exit 1
fi 