<?php

namespace App\Controller;

use App\Entity\Activity;
use App\Entity\Reservation;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/reservations')]
final class ReservationController extends AbstractController
{
    private function addCorsHeaders(JsonResponse $response): JsonResponse
    {
        $response->headers->set('Access-Control-Allow-Origin', 'http://localhost:3000');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $response->headers->set('Access-Control-Allow-Credentials', 'true');
        return $response;
    }

    #[Route('', name: 'app_reservations_list', methods: ['GET', 'OPTIONS'])]
    #[IsGranted('ROLE_USER')]
    public function index(Request $request, EntityManagerInterface $entityManager): JsonResponse
    {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $user = $this->getUser();
        $reservations = $entityManager->getRepository(Reservation::class)->findBy(['user' => $user]);
        
        $reservationData = [];
        foreach ($reservations as $reservation) {
            $reservationData[] = [
                'id' => $reservation->getId(),
                'activity' => [
                    'id' => $reservation->getActivity()->getId(),
                    'name' => $reservation->getActivity()->getName(),
                    'activityType' => $reservation->getActivity()->getActivityType(),
                    'location' => $reservation->getActivity()->getLocation(),
                    'price' => $reservation->getActivity()->getPrice()
                ],
                'dateTime' => $reservation->getDateTime()->format('Y-m-d H:i:s'),
                'status' => $reservation->getStatus(),
                'createdAt' => $reservation->getCreatedAt()->format('Y-m-d H:i:s'),
                'updatedAt' => $reservation->getUpdatedAt()->format('Y-m-d H:i:s')
            ];
        }

        $response = $this->json($reservationData);
        return $this->addCorsHeaders($response);
    }

    #[Route('/{id}', name: 'app_reservations_show', methods: ['GET', 'OPTIONS'])]
    #[IsGranted('ROLE_USER')]
    public function show(Request $request, Reservation $reservation): JsonResponse
    {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $user = $this->getUser();
        

        if ($reservation->getUser()->getId() !== $user->getId()) {
            $response = $this->json([
                'error' => 'Accès non autorisé'
            ], Response::HTTP_FORBIDDEN);
            return $this->addCorsHeaders($response);
        }

        $response = $this->json([
            'id' => $reservation->getId(),
            'activity' => [
                'id' => $reservation->getActivity()->getId(),
                'name' => $reservation->getActivity()->getName(),
                'description' => $reservation->getActivity()->getDescription(),
                'activityType' => $reservation->getActivity()->getActivityType(),
                'location' => $reservation->getActivity()->getLocation(),
                'price' => $reservation->getActivity()->getPrice()
            ],
            'dateTime' => $reservation->getDateTime()->format('Y-m-d H:i:s'),
            'status' => $reservation->getStatus(),
            'createdAt' => $reservation->getCreatedAt()->format('Y-m-d H:i:s'),
            'updatedAt' => $reservation->getUpdatedAt()->format('Y-m-d H:i:s')
        ]);
        return $this->addCorsHeaders($response);
    }

    #[Route('', name: 'app_reservations_create', methods: ['POST', 'OPTIONS'])]
    #[IsGranted('ROLE_USER')]
    public function create(
        Request $request,
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator
    ): JsonResponse {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $data = json_decode($request->getContent(), true);
        
        if (!$data || !isset($data['activityId']) || !isset($data['dateTime'])) {
            $response = $this->json([
                'error' => 'Activity ID et date/heure sont requis'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }

        $activity = $entityManager->getRepository(Activity::class)->find($data['activityId']);
        if (!$activity) {
            $response = $this->json([
                'error' => 'Activité non trouvée'
            ], Response::HTTP_NOT_FOUND);
            return $this->addCorsHeaders($response);
        }


        if ($activity->getRemainingSpots() <= 0) {
            $response = $this->json([
                'error' => 'Aucune place disponible pour cette activité'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }


        $dateTime = new \DateTime($data['dateTime']);
        $availableSlots = $activity->getAvailableSlots();
        $slotFound = false;
        
        foreach ($availableSlots as $slot) {
            if (new \DateTime($slot) == $dateTime) {
                $slotFound = true;
                break;
            }
        }
        
        if (!$slotFound) {
            $response = $this->json([
                'error' => 'Créneau non disponible pour cette activité'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }


        $existingReservation = $entityManager->getRepository(Reservation::class)->findOneBy([
            'user' => $this->getUser(),
            'activity' => $activity,
            'dateTime' => $dateTime
        ]);

        if ($existingReservation) {
            $response = $this->json([
                'error' => 'Vous avez déjà une réservation pour ce créneau'
            ], Response::HTTP_CONFLICT);
            return $this->addCorsHeaders($response);
        }

        $reservation = new Reservation();
        $reservation->setUser($this->getUser());
        $reservation->setActivity($activity);
        $reservation->setDateTime($dateTime);
        $reservation->setStatus('confirmed');

        $errors = $validator->validate($reservation);
        if (count($errors) > 0) {
            $errorMessages = [];
            foreach ($errors as $error) {
                $errorMessages[] = $error->getMessage();
            }
            $response = $this->json([
                'error' => 'Données invalides',
                'details' => $errorMessages
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }


        $activity->setRemainingSpots($activity->getRemainingSpots() - 1);

        $entityManager->persist($reservation);
        $entityManager->flush();

        $response = $this->json([
            'message' => 'Réservation créée avec succès',
            'reservation' => [
                'id' => $reservation->getId(),
                'activity' => [
                    'id' => $activity->getId(),
                    'name' => $activity->getName(),
                    'activityType' => $activity->getActivityType(),
                    'location' => $activity->getLocation(),
                    'price' => $activity->getPrice()
                ],
                'dateTime' => $reservation->getDateTime()->format('Y-m-d H:i:s'),
                'status' => $reservation->getStatus(),
                'createdAt' => $reservation->getCreatedAt()->format('Y-m-d H:i:s')
            ]
        ], Response::HTTP_CREATED);
        return $this->addCorsHeaders($response);
    }

    #[Route('/{id}/cancel', name: 'app_reservations_cancel', methods: ['PUT', 'OPTIONS'])]
    #[IsGranted('ROLE_USER')]
    public function cancel(
        Request $request,
        Reservation $reservation,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $user = $this->getUser();
        

        if ($reservation->getUser()->getId() !== $user->getId()) {
            $response = $this->json([
                'error' => 'Accès non autorisé'
            ], Response::HTTP_FORBIDDEN);
            return $this->addCorsHeaders($response);
        }


        if ($reservation->getStatus() === 'cancelled') {
            $response = $this->json([
                'error' => 'Cette réservation est déjà annulée'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }


        if ($reservation->getDateTime() < new \DateTime()) {
            $response = $this->json([
                'error' => 'Impossible d\'annuler une réservation passée'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }

        $reservation->setStatus('cancelled');
        

        $activity = $reservation->getActivity();
        $activity->setRemainingSpots($activity->getRemainingSpots() + 1);

        $entityManager->flush();

        $response = $this->json([
            'message' => 'Réservation annulée avec succès',
            'reservation' => [
                'id' => $reservation->getId(),
                'status' => $reservation->getStatus(),
                'updatedAt' => $reservation->getUpdatedAt()->format('Y-m-d H:i:s')
            ]
        ]);
        return $this->addCorsHeaders($response);
    }
}
