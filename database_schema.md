# 🗄️ Schéma de Base de Données - Aquarhone

## 📊 Vue d'ensemble

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      USER       │    │    ACTIVITY     │    │   RESERVATION   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ id (PK)         │    │ id (PK)         │    │ id (PK)         │
│ email (UNIQUE)  │    │ name            │    │ user_id (FK)    │
│ password        │    │ description     │    │ activity_id(FK) │
│ roles (JSON)    │    │ activity_type   │    │ date_time       │
│                 │    │ location        │    │ status          │
│                 │    │ available_slots │    │ created_at      │
│                 │    │ price           │    │ updated_at      │
│                 │    │ remaining_spots │    │                 │
│                 │    │ created_at      │    │                 │
│                 │    │ updated_at      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      RELATIONS            │
                    │                           │
                    │ User 1:N Reservation      │
                    │ Activity 1:N Reservation │
                    └───────────────────────────┘
```

## 🏗️ Structure Détaillée

### 📋 Table `user`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identifiant unique |
| `email` | VARCHAR(180) | UNIQUE, NOT NULL | Email de l'utilisateur |
| `password` | VARCHAR(255) | NOT NULL | Mot de passe hashé |
| `roles` | JSON | NOT NULL | Rôles utilisateur (ROLE_USER, ROLE_ADMIN) |

**Index :**
- `UNIQ_IDENTIFIER_EMAIL` sur `email`

**Relations :**
- `OneToMany` vers `reservation` (1 utilisateur → N réservations)

### 🏊‍♂️ Table `activity`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identifiant unique |
| `name` | VARCHAR(255) | NOT NULL | Nom de l'activité |
| `description` | TEXT | NOT NULL | Description détaillée |
| `activity_type` | VARCHAR(100) | NOT NULL | Type (kayak, paddle, canoe, croisiere) |
| `location` | VARCHAR(255) | NOT NULL | Lieu de l'activité |
| `available_slots` | JSON | NOT NULL | Créneaux disponibles |
| `price` | DECIMAL(10,2) | NOT NULL, POSITIVE | Prix en euros |
| `remaining_spots` | INTEGER | NOT NULL, >= 0 | Places restantes |
| `created_at` | DATETIME_IMMUTABLE | NOT NULL | Date de création |
| `updated_at` | DATETIME_IMMUTABLE | NOT NULL | Date de modification |

**Contraintes :**
- `activity_type` doit être dans : ['kayak', 'paddle', 'canoe', 'croisiere']
- `price` doit être positif
- `remaining_spots` doit être >= 0

**Relations :**
- `OneToMany` vers `reservation` (1 activité → N réservations)

### 📅 Table `reservation`

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identifiant unique |
| `user_id` | INTEGER | FOREIGN KEY, NOT NULL | Référence vers user |
| `activity_id` | INTEGER | FOREIGN KEY, NOT NULL | Référence vers activity |
| `date_time` | DATETIME | NOT NULL | Date et heure de réservation |
| `status` | VARCHAR(20) | NOT NULL, DEFAULT 'pending' | Statut (pending, confirmed, cancelled) |
| `created_at` | DATETIME | NOT NULL | Date de création |
| `updated_at` | DATETIME | NOT NULL | Date de modification |

**Clés étrangères :**
- `user_id` → `user.id`
- `activity_id` → `activity.id`

**Contraintes :**
- `status` doit être dans : ['pending', 'confirmed', 'cancelled']

**Relations :**
- `ManyToOne` vers `user` (N réservations → 1 utilisateur)
- `ManyToOne` vers `activity` (N réservations → 1 activité)

## 🔗 Relations et Cardinalités

### Relation User ↔ Reservation
```
User (1) ──────── (N) Reservation
```
- **Cardinalité :** One-to-Many
- **Description :** Un utilisateur peut avoir plusieurs réservations
- **Cascade :** Orphan removal (suppression automatique des réservations si l'utilisateur est supprimé)

### Relation Activity ↔ Reservation
```
Activity (1) ──────── (N) Reservation
```
- **Cardinalité :** One-to-Many
- **Description :** Une activité peut avoir plusieurs réservations
- **Cascade :** Orphan removal (suppression automatique des réservations si l'activité est supprimée)

## 📝 Modèles d'Entités

### 🧑‍💼 Entité User
```php
class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    private ?int $id;
    private ?string $email;
    private array $roles;
    private ?string $password;
    private Collection $reservations;
    
    // Méthodes d'interface Symfony Security
    public function getUserIdentifier(): string;
    public function getRoles(): array;
    public function getPassword(): ?string;
    
    // Gestion des réservations
    public function getReservations(): Collection;
    public function addReservation(Reservation $reservation): static;
    public function removeReservation(Reservation $reservation): static;
}
```

### 🏄‍♂️ Entité Activity
```php
class Activity
{
    private ?int $id;
    private ?string $name;
    private ?string $description;
    private ?string $activityType;
    private ?string $location;
    private array $availableSlots;
    private ?string $price;
    private ?int $remainingSpots;
    private ?\DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt;
    private Collection $reservations;
    
    // Gestion des réservations
    public function getReservations(): Collection;
    public function addReservation(Reservation $reservation): static;
    public function removeReservation(Reservation $reservation): static;
    
    // Lifecycle callbacks
    #[ORM\PreUpdate]
    public function setUpdatedAtValue(): void;
}
```

### 📋 Entité Reservation
```php
class Reservation
{
    private ?int $id;
    private ?User $user;
    private ?Activity $activity;
    private ?\DateTimeInterface $dateTime;
    private ?string $status;
    private ?\DateTimeInterface $createdAt;
    private ?\DateTimeInterface $updatedAt;
    
    // Lifecycle callbacks
    #[ORM\PreUpdate]
    public function setUpdatedAtValue(): void;
}
```

## 🔒 Contraintes et Validation

### Validation des Données
- **Email :** Format email valide, unique en base
- **Password :** Hashé avec bcrypt
- **Roles :** Array JSON avec ROLE_USER par défaut
- **Activity Type :** Enum : kayak, paddle, canoe, croisiere
- **Price :** Décimal positif
- **Remaining Spots :** Entier >= 0
- **Status :** Enum : pending, confirmed, cancelled

### Contraintes de Base
- **Clés primaires :** Auto-incrémentées
- **Clés étrangères :** NOT NULL avec cascade
- **Timestamps :** Automatiques (created_at, updated_at)
- **Index unique :** Email utilisateur

## 🗃️ Scripts SQL

### Création des Tables
```sql
-- Table user
CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(180) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    roles JSON NOT NULL
);

-- Table activity
CREATE TABLE activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    activity_type VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    available_slots JSON NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    remaining_spots INTEGER NOT NULL,
    created_at DATETIME_IMMUTABLE NOT NULL,
    updated_at DATETIME_IMMUTABLE NOT NULL
);

-- Table reservation
CREATE TABLE reservation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    activity_id INTEGER NOT NULL,
    date_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (activity_id) REFERENCES activity(id)
);
```

### Index Recommandés
```sql
-- Index pour les performances
CREATE INDEX idx_user_email ON user(email);
CREATE INDEX idx_activity_type ON activity(activity_type);
CREATE INDEX idx_reservation_user ON reservation(user_id);
CREATE INDEX idx_reservation_activity ON reservation(activity_id);
CREATE INDEX idx_reservation_datetime ON reservation(date_time);
CREATE INDEX idx_reservation_status ON reservation(status);
```

## 📊 Exemples de Données

### Utilisateur Admin
```sql
INSERT INTO user (email, password, roles) VALUES (
    'superadmin@aquarhone.com',
    '$2y$13$ftnWPPBwTk.llQ9mtxUK.e2SEdR/IguX5zf8cKM5VDNxCCNF0v9Y6',
    '["ROLE_ADMIN","ROLE_USER"]'
);
```

### Activité
```sql
INSERT INTO activity (name, description, activity_type, location, available_slots, price, remaining_spots, created_at, updated_at) VALUES (
    'Kayak en mer',
    'Découvrez la côte en kayak de mer',
    'kayak',
    'Port de plaisance',
    '["2024-07-20 09:00", "2024-07-20 14:00"]',
    45.00,
    8,
    '2024-01-15 10:00:00',
    '2024-01-15 10:00:00'
);
```

### Réservation
```sql
INSERT INTO reservation (user_id, activity_id, date_time, status, created_at, updated_at) VALUES (
    1,
    1,
    '2024-07-20 09:00:00',
    'confirmed',
    '2024-01-15 11:00:00',
    '2024-01-15 11:00:00'
);
```

## 🔄 Migrations Doctrine

Le projet utilise Doctrine ORM avec des migrations automatiques :

```bash
# Créer une migration
php bin/console make:migration

# Exécuter les migrations
php bin/console doctrine:migrations:migrate

# Voir le statut des migrations
php bin/console doctrine:migrations:status
```

## 📈 Optimisations Recommandées

1. **Index composites** pour les requêtes fréquentes
2. **Partitioning** pour les grandes tables de réservations
3. **Archivage** des anciennes réservations
4. **Cache** pour les activités populaires
5. **Monitoring** des performances avec des requêtes lentes 