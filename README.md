# Back-Aquarhone - API Symfony

Backend Symfony avec authentification JWT et système de réservation d'activités.

## 🚀 Démarrage rapide

### 1. Installation
```bash
# Cloner le projet
git clone git@github.com:Dev02JL/my-back-aquarhone.git
cd back-aquarhone

# Installer les dépendances
composer install
```

### 2. Configuration
```bash
# Créer la base de données
php bin/console doctrine:migrations:migrate

# Créer un admin
php bin/console app:create-admin admin@aquarhone.com admin123

# Remplir avec des données de test
./fill_jdd.sh
```

### 3. Lancer le serveur
```bash
# Démarrer en HTTP (important pour le frontend)
symfony server:start -d --port=8000 --no-tls
```

L'API est accessible sur `http://localhost:8000`

## 📋 Tests rapides

```bash
# Tester tout le système
./run_tests_with_jdd.sh
```

## 🔑 Comptes de test

- **Admin :** `admin@aquarhone.com` / `admin123`
- **Utilisateur :** `test@example.com` / `password123`

## 📡 API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Profil utilisateur

### Activités
- `GET /api/activities` - Liste des activités
- `GET /api/activities/{id}` - Détails d'une activité
- `POST /api/activities` - Créer (Admin)
- `PUT /api/activities/{id}` - Modifier (Admin)
- `DELETE /api/activities/{id}` - Supprimer (Admin)

### Réservations
- `GET /api/reservations` - Mes réservations
- `POST /api/reservations` - Créer une réservation
- `PUT /api/reservations/{id}/cancel` - Annuler

### Utilisateurs (Admin)
- `GET /api/users` - Liste des utilisateurs
- `POST /api/users` - Créer un utilisateur

## 🔧 Configuration CORS

Le projet accepte les requêtes depuis `http://localhost:3000` (frontend Next.js).

## 📁 Structure

```
src/
├── Controller/     # API endpoints
├── Entity/         # Modèles de données
├── Repository/     # Accès aux données
└── Command/        # Commandes console
``` 