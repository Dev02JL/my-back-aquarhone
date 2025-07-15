<?php

namespace App\Entity;

use App\Repository\ActivityRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: ActivityRepository::class)]
class Activity
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    #[Assert\NotBlank(message: 'Le nom est requis')]
    private ?string $name = null;

    #[ORM\Column(type: 'text')]
    #[Assert\NotBlank(message: 'La description est requise')]
    private ?string $description = null;

    #[ORM\Column(length: 100)]
    #[Assert\NotBlank(message: 'Le type d\'activité est requis')]
    #[Assert\Choice(choices: ['kayak', 'paddle', 'canoe', 'croisiere'], message: 'Type d\'activité invalide')]
    private ?string $activityType = null;

    #[ORM\Column(length: 255)]
    #[Assert\NotBlank(message: 'Le lieu est requis')]
    private ?string $location = null;

    #[ORM\Column(type: 'json')]
    private array $availableSlots = [];

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Assert\NotBlank(message: 'Le prix est requis')]
    #[Assert\Positive(message: 'Le prix doit être positif')]
    private ?string $price = null;

    #[ORM\Column]
    #[Assert\NotBlank(message: 'Le nombre de places est requis')]
    #[Assert\PositiveOrZero(message: 'Le nombre de places doit être positif ou zéro')]
    private ?int $remainingSpots = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;

    #[ORM\Column]
    private ?\DateTimeImmutable $updatedAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getActivityType(): ?string
    {
        return $this->activityType;
    }

    public function setActivityType(string $activityType): static
    {
        $this->activityType = $activityType;
        return $this;
    }

    public function getLocation(): ?string
    {
        return $this->location;
    }

    public function setLocation(string $location): static
    {
        $this->location = $location;
        return $this;
    }

    public function getAvailableSlots(): array
    {
        return $this->availableSlots;
    }

    public function setAvailableSlots(array $availableSlots): static
    {
        $this->availableSlots = $availableSlots;
        return $this;
    }

    public function getPrice(): ?string
    {
        return $this->price;
    }

    public function setPrice(string $price): static
    {
        $this->price = $price;
        return $this;
    }

    public function getRemainingSpots(): ?int
    {
        return $this->remainingSpots;
    }

    public function setRemainingSpots(int $remainingSpots): static
    {
        $this->remainingSpots = $remainingSpots;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(\DateTimeImmutable $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[ORM\PreUpdate]
    public function setUpdatedAtValue(): void
    {
        $this->updatedAt = new \DateTimeImmutable();
    }
}
