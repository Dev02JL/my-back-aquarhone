# Back-Aquarhone - API Symfony

Backend Symfony avec gestion des utilisateurs et des rôles (USER et ADMIN), authentification JWT et système de réservation d'activités.

## Prérequis

- PHP 8.2 ou supérieur
- Composer
- SQLite (inclus avec PHP)
- Symfony CLI (recommandé)

## Installation

1. **Cloner le projet**
   ```bash
   git clone git@github.com:Dev02JL/my-back-aquarhone.git
   cd back-aquarhone
   ```

2. **Installer les dépendances**
   ```bash
   composer install
   ```

3. **Configurer l'environnement**
   ```bash
   cp .env.example .env.local
   ```
   
   Modifier `DATABASE_URL` dans `.env.local` si nécessaire :
   ```env
   DATABASE_URL="sqlite:///%kernel.project_dir%/var/app.db"
   ```

4. **Créer la base de données**
   ```bash
   php bin/console doctrine:migrations:migrate
   ```

5. **Créer un utilisateur administrateur**
   ```bash
   php bin/console app:create-admin admin@aquarhone.com admin123
   ```

6. **Démarrer le serveur**
   
   **Option 1 : Avec Symfony CLI (recommandé)**
   ```bash
   symfony server:start -d --port=8000 --no-tls
   ```
   
   **Option 2 : Avec PHP built-in server**
   ```bash
   php -S localhost:8000 -t public
   ```

   **⚠️ Important :** Le serveur doit être démarré en mode HTTP (sans TLS) pour éviter les problèmes CORS avec le frontend.

L'API sera accessible sur `http://localhost:8000`

## Configuration CORS

Le projet est configuré pour accepter les requêtes depuis le frontend Next.js (`http://localhost:3000`).

- **Bundle utilisé :** NelmioCorsBundle
- **Origines autorisées :** `http://localhost:3000`, `http://127.0.0.1:3000`
- **Méthodes autorisées :** GET, POST, PUT, PATCH, DELETE, OPTIONS
- **Headers autorisés :** Content-Type, Authorization, X-Requested-With

## Authentification JWT

L'API utilise l'authentification JWT (JSON Web Token) pour sécuriser les endpoints.

### Obtenir un token JWT

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@aquarhone.com","password":"admin123"}'
```

**Réponse :**
```json
{
  "message": "Connexion réussie",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "admin@aquarhone.com",
    "roles": ["ROLE_ADMIN", "ROLE_USER"]
  }
}
```

### Utiliser le token JWT

Ajoutez le header `Authorization: Bearer <token>` à toutes vos requêtes :

```bash
curl -X GET http://localhost:8000/api/activities \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."
```

## API Endpoints

### Authentification

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/auth/register` | Inscription d'un utilisateur |
| POST | `/api/auth/login` | Connexion et obtention d'un token JWT |
| GET | `/api/auth/me` | Profil utilisateur connecté (nécessite JWT) |

### Gestion des utilisateurs (Admin uniquement)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/users` | Liste des utilisateurs |
| GET | `/api/users/{id}` | Détails d'un utilisateur |
| POST | `/api/users` | Créer un utilisateur |
| PUT | `/api/users/{id}` | Modifier un utilisateur |
| DELETE | `/api/users/{id}` | Supprimer un utilisateur |

### Gestion des activités

| Méthode | Endpoint | Description | Accès |
|---------|----------|-------------|-------|
| GET | `/api/activities` | Liste des activités | Utilisateurs authentifiés |
| GET | `/api/activities/{id}` | Détails d'une activité | Utilisateurs authentifiés |
| POST | `/api/activities` | Créer une activité | Admin uniquement |
| PUT | `/api/activities/{id}` | Modifier une activité | Admin uniquement |
| DELETE | `/api/activities/{id}` | Supprimer une activité | Admin uniquement |

### Gestion des réservations (Utilisateurs authentifiés)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/reservations` | Liste des réservations de l'utilisateur |
| GET | `/api/reservations/{id}` | Détails d'une réservation |
| POST | `/api/reservations` | Créer une réservation |
| PUT | `/api/reservations/{id}/cancel` | Annuler une réservation |

## Exemples d'utilisation

### Inscription
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

### Connexion et obtention du token
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@aquarhone.com","password":"admin123"}'
```

### Consulter les activités (Utilisateur ou Admin)
```bash
curl -X GET http://localhost:8000/api/activities \
  -H "Authorization: Bearer <votre_token_jwt>"
```

### Consulter une activité spécifique (Utilisateur ou Admin)
```bash
curl -X GET http://localhost:8000/api/activities/1 \
  -H "Authorization: Bearer <votre_token_jwt>"
```

### Créer une réservation (Utilisateur)
```bash
curl -X POST http://localhost:8000/api/reservations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <votre_token_jwt>" \
  -d '{
    "activityId": 1,
    "dateTime": "2024-07-20 09:00:00"
  }'
```

### Consulter ses réservations (Utilisateur)
```bash
curl -X GET http://localhost:8000/api/reservations \
  -H "Authorization: Bearer <votre_token_jwt>"
```

### Annuler une réservation (Utilisateur)
```bash
curl -X PUT http://localhost:8000/api/reservations/1/cancel \
  -H "Authorization: Bearer <votre_token_jwt>"
```

### Créer un utilisateur (Admin)
```bash
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <votre_token_jwt>" \
  -d '{"email":"newuser@example.com","password":"password123","roles":["ROLE_USER"]}'
```

### Créer une activité (Admin)
```bash
curl -X POST http://localhost:8000/api/activities \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <votre_token_jwt>" \
  -d '{
    "name": "Kayak en mer",
    "description": "Découvrez la côte en kayak",
    "activityType": "kayak",
    "location": "Port de plaisance",
    "price": "45.00",
    "remainingSpots": 10,
    "availableSlots": ["2024-07-20 09:00", "2024-07-21 14:00"]
  }'
```

### Modifier une activité (Admin)
```bash
curl -X PUT http://localhost:8000/api/activities/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <votre_token_jwt>" \
  -d '{
    "price": "50.00",
    "remainingSpots": 8
  }'
```

## Rôles

- `ROLE_USER` : Utilisateur standard (peut consulter les activités et gérer ses réservations)
- `ROLE_ADMIN` : Administrateur (accès complet à l'API)

## Structure du projet

```
back-aquarhone/
├── src/
│   ├── Controller/
│   │   ├── AuthController.php    # API d'authentification JWT
│   │   ├── UserController.php    # API de gestion des utilisateurs
│   │   ├── ActivityController.php # API de gestion des activités
│   │   └── ReservationController.php # API de gestion des réservations
│   ├── Entity/
│   │   ├── User.php             # Entité utilisateur
│   │   ├── Activity.php         # Entité activité
│   │   └── Reservation.php      # Entité réservation
│   ├── Repository/
│   │   ├── UserRepository.php   # Repository utilisateur
│   │   ├── ActivityRepository.php # Repository activité
│   │   └── ReservationRepository.php # Repository réservation
│   └── Command/
│       └── CreateAdminCommand.php # Commande pour créer un admin
├── config/
│   ├── jwt/                     # Clés JWT (privée/publique)
│   └── packages/
│       ├── lexik_jwt_authentication.yaml # Configuration JWT
│       ├── nelmio_cors.yaml     # Configuration CORS
│       └── security.yaml        # Configuration sécurité
├── migrations/                  # Migrations de base de données
├── public/                     # Point d'entrée web
└── var/                        # Cache et base de données
```

## Base de données

- **Type** : SQLite
- **Fichier** : `var/app.db`
- **Tables** : 
  - `user` (id, email, roles, password)
  - `activity` (id, name, description, activity_type, location, price, remaining_spots, available_slots)
  - `reservation` (id, user_id, activity_id, date_time, status)

## Développement

### Commandes utiles

```bash
# Vider le cache
php bin/console cache:clear

# Voir les routes disponibles
php bin/console debug:router

# Voir les services disponibles
php bin/console debug:container

# Créer une migration
php bin/console make:migration

# Exécuter les migrations
php bin/console doctrine:migrations:migrate

# Créer un utilisateur admin
php bin/console app:create-admin email@example.com password
```

### Tests

```bash
# Lancer les tests
php bin/phpunit

# Tests avec données de test
./run_tests_with_jdd.sh
```

## Dépannage

### Problèmes CORS
Si vous rencontrez des erreurs CORS :
1. Vérifiez que le serveur est démarré en mode HTTP (`--no-tls`)
2. Vérifiez que le frontend est sur `http://localhost:3000`
3. Videz le cache : `php bin/console cache:clear`

### Problèmes d'authentification
1. Vérifiez que les clés JWT sont générées : `php bin/console lexik:jwt:generate-keypair`
2. Vérifiez que l'utilisateur existe : `php bin/console app:create-admin admin@aquarhone.com admin123`

### Problèmes de base de données
1. Vérifiez que les migrations sont à jour : `php bin/console doctrine:migrations:migrate`
2. Vérifiez que la base de données existe : `ls var/app.db` 