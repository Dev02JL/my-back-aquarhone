# Back-Aquarhone - API Symfony

Backend Symfony avec gestion des utilisateurs et des rôles (USER et ADMIN).

## Prérequis

- PHP 8.2 ou supérieur
- Composer
- SQLite (inclus avec PHP)

## Installation

1. **Cloner le projet**
   ```bash
   git clone <url-du-repo>
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
   ```bash
   php -S localhost:8000 -t public
   ```

L'API sera accessible sur `http://localhost:8000`

## API Endpoints

### Authentification

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/auth/register` | Inscription d'un utilisateur |
| POST | `/api/auth/login` | Connexion (à implémenter) |
| GET | `/api/auth/me` | Profil utilisateur connecté |

### Gestion des utilisateurs (Admin uniquement)

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/users` | Liste des utilisateurs |
| GET | `/api/users/{id}` | Détails d'un utilisateur |
| POST | `/api/users` | Créer un utilisateur |
| PUT | `/api/users/{id}` | Modifier un utilisateur |
| DELETE | `/api/users/{id}` | Supprimer un utilisateur |

## Exemples d'utilisation

### Inscription
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

### Créer un utilisateur (Admin)
```bash
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser@example.com","password":"password123","roles":["ROLE_USER"]}'
```

## Rôles

- `ROLE_USER` : Utilisateur standard
- `ROLE_ADMIN` : Administrateur (accès complet à l'API)

## Structure du projet

```
back-aquarhone/
├── src/
│   ├── Controller/
│   │   ├── AuthController.php    # API d'authentification
│   │   └── UserController.php    # API de gestion des utilisateurs
│   ├── Entity/
│   │   └── User.php             # Entité utilisateur
│   ├── Repository/
│   │   └── UserRepository.php   # Repository utilisateur
│   └── Command/
│       └── CreateAdminCommand.php # Commande pour créer un admin
├── config/                      # Configuration Symfony
├── migrations/                  # Migrations de base de données
├── public/                     # Point d'entrée web
└── var/                        # Cache et base de données
```

## Base de données

- **Type** : SQLite
- **Fichier** : `var/app.db`
- **Tables** : `user` (id, email, roles, password)

## Commandes utiles

```bash
# Vider le cache
php bin/console cache:clear

# Lister les routes
php bin/console debug:router

# Voir les utilisateurs en base
php bin/console doctrine:query:sql "SELECT * FROM user"

# Créer une migration
php bin/console make:migration

# Appliquer les migrations
php bin/console doctrine:migrations:migrate
```

## Développement

### Ajouter une nouvelle route
1. Créer/modifier un contrôleur dans `src/Controller/`
2. Ajouter l'attribut `#[Route()]`
3. Vider le cache : `php bin/console cache:clear`

### Ajouter un nouveau champ à l'entité User
1. Modifier `src/Entity/User.php`
2. Créer une migration : `php bin/console make:migration`
3. Appliquer la migration : `php bin/console doctrine:migrations:migrate`

## Support

Pour toute question ou problème, consulter la documentation Symfony ou créer une issue.
