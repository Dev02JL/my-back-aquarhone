<?php

namespace App\Controller;

use App\Entity\Activity;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/activities')]
final class ActivityController extends AbstractController
{
    #[Route('', name: 'app_activities_list', methods: ['GET'])]
    #[IsGranted('ROLE_ADMIN')]
    public function index(EntityManagerInterface $entityManager): JsonResponse
    {
        $activities = $entityManager->getRepository(Activity::class)->findAll();
        
        $activityData = [];
        foreach ($activities as $activity) {
            $activityData[] = [
                'id' => $activity->getId(),
                'name' => $activity->getName(),
                'description' => $activity->getDescription(),
                'activityType' => $activity->getActivityType(),
                'location' => $activity->getLocation(),
                'availableSlots' => $activity->getAvailableSlots(),
                'price' => $activity->getPrice(),
                'remainingSpots' => $activity->getRemainingSpots(),
                'createdAt' => $activity->getCreatedAt()->format('Y-m-d H:i:s'),
                'updatedAt' => $activity->getUpdatedAt()->format('Y-m-d H:i:s')
            ];
        }

        return $this->json($activityData);
    }

    #[Route('/{id}', name: 'app_activities_show', methods: ['GET'])]
    #[IsGranted('ROLE_ADMIN')]
    public function show(Activity $activity): JsonResponse
    {
        return $this->json([
            'id' => $activity->getId(),
            'name' => $activity->getName(),
            'description' => $activity->getDescription(),
            'activityType' => $activity->getActivityType(),
            'location' => $activity->getLocation(),
            'availableSlots' => $activity->getAvailableSlots(),
            'price' => $activity->getPrice(),
            'remainingSpots' => $activity->getRemainingSpots(),
            'createdAt' => $activity->getCreatedAt()->format('Y-m-d H:i:s'),
            'updatedAt' => $activity->getUpdatedAt()->format('Y-m-d H:i:s')
        ]);
    }

    #[Route('', name: 'app_activities_create', methods: ['POST'])]
    #[IsGranted('ROLE_ADMIN')]
    public function create(
        Request $request,
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);
        
        if (!$data || !isset($data['name']) || !isset($data['description']) || !isset($data['activityType']) || !isset($data['location']) || !isset($data['price']) || !isset($data['remainingSpots'])) {
            return $this->json([
                'error' => 'Tous les champs sont requis : name, description, activityType, location, price, remainingSpots'
            ], Response::HTTP_BAD_REQUEST);
        }

        $activity = new Activity();
        $activity->setName($data['name']);
        $activity->setDescription($data['description']);
        $activity->setActivityType($data['activityType']);
        $activity->setLocation($data['location']);
        $activity->setPrice($data['price']);
        $activity->setRemainingSpots($data['remainingSpots']);
        
        if (isset($data['availableSlots'])) {
            $activity->setAvailableSlots($data['availableSlots']);
        }

        $errors = $validator->validate($activity);
        if (count($errors) > 0) {
            $errorMessages = [];
            foreach ($errors as $error) {
                $errorMessages[] = $error->getMessage();
            }
            return $this->json([
                'error' => 'Données invalides',
                'details' => $errorMessages
            ], Response::HTTP_BAD_REQUEST);
        }

        $entityManager->persist($activity);
        $entityManager->flush();

        return $this->json([
            'message' => 'Activité créée avec succès',
            'activity' => [
                'id' => $activity->getId(),
                'name' => $activity->getName(),
                'description' => $activity->getDescription(),
                'activityType' => $activity->getActivityType(),
                'location' => $activity->getLocation(),
                'availableSlots' => $activity->getAvailableSlots(),
                'price' => $activity->getPrice(),
                'remainingSpots' => $activity->getRemainingSpots(),
                'createdAt' => $activity->getCreatedAt()->format('Y-m-d H:i:s'),
                'updatedAt' => $activity->getUpdatedAt()->format('Y-m-d H:i:s')
            ]
        ], Response::HTTP_CREATED);
    }

    #[Route('/{id}', name: 'app_activities_update', methods: ['PUT'])]
    #[IsGranted('ROLE_ADMIN')]
    public function update(
        Activity $activity,
        Request $request,
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);
        
        if (!$data) {
            return $this->json([
                'error' => 'Données requises'
            ], Response::HTTP_BAD_REQUEST);
        }

        if (isset($data['name'])) {
            $activity->setName($data['name']);
        }

        if (isset($data['description'])) {
            $activity->setDescription($data['description']);
        }

        if (isset($data['activityType'])) {
            $activity->setActivityType($data['activityType']);
        }

        if (isset($data['location'])) {
            $activity->setLocation($data['location']);
        }

        if (isset($data['availableSlots'])) {
            $activity->setAvailableSlots($data['availableSlots']);
        }

        if (isset($data['price'])) {
            $activity->setPrice($data['price']);
        }

        if (isset($data['remainingSpots'])) {
            $activity->setRemainingSpots($data['remainingSpots']);
        }

        $errors = $validator->validate($activity);
        if (count($errors) > 0) {
            $errorMessages = [];
            foreach ($errors as $error) {
                $errorMessages[] = $error->getMessage();
            }
            return $this->json([
                'error' => 'Données invalides',
                'details' => $errorMessages
            ], Response::HTTP_BAD_REQUEST);
        }

        $entityManager->flush();

        return $this->json([
            'message' => 'Activité mise à jour avec succès',
            'activity' => [
                'id' => $activity->getId(),
                'name' => $activity->getName(),
                'description' => $activity->getDescription(),
                'activityType' => $activity->getActivityType(),
                'location' => $activity->getLocation(),
                'availableSlots' => $activity->getAvailableSlots(),
                'price' => $activity->getPrice(),
                'remainingSpots' => $activity->getRemainingSpots(),
                'createdAt' => $activity->getCreatedAt()->format('Y-m-d H:i:s'),
                'updatedAt' => $activity->getUpdatedAt()->format('Y-m-d H:i:s')
            ]
        ]);
    }

    #[Route('/{id}', name: 'app_activities_delete', methods: ['DELETE'])]
    #[IsGranted('ROLE_ADMIN')]
    public function delete(Activity $activity, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($activity);
        $entityManager->flush();

        return $this->json([
            'message' => 'Activité supprimée avec succès'
        ]);
    }
}
