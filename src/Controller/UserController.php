<?php

namespace App\Controller;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use Symfony\Component\Validator\Validator\ValidatorInterface;

#[Route('/api/users')]
#[IsGranted('ROLE_ADMIN')]
final class UserController extends AbstractController
{
    private function addCorsHeaders(JsonResponse $response): JsonResponse
    {
        $response->headers->set('Access-Control-Allow-Origin', 'http://localhost:3000');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $response->headers->set('Access-Control-Allow-Credentials', 'true');
        return $response;
    }

    #[Route('', name: 'app_users_list', methods: ['GET', 'OPTIONS'])]
    public function index(Request $request, EntityManagerInterface $entityManager): JsonResponse
    {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $users = $entityManager->getRepository(User::class)->findAll();
        
        $userData = [];
        foreach ($users as $user) {
            $userData[] = [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'roles' => $user->getRoles()
            ];
        }

        $response = $this->json($userData);
        return $this->addCorsHeaders($response);
    }

    #[Route('/{id}', name: 'app_users_show', methods: ['GET', 'OPTIONS'])]
    public function show(Request $request, User $user): JsonResponse
    {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $response = $this->json([
            'id' => $user->getId(),
            'email' => $user->getEmail(),
            'roles' => $user->getRoles()
        ]);
        return $this->addCorsHeaders($response);
    }

    #[Route('', name: 'app_users_create', methods: ['POST', 'OPTIONS'])]
    public function create(
        Request $request,
        UserPasswordHasherInterface $passwordHasher,
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator
    ): JsonResponse {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $data = json_decode($request->getContent(), true);
        
        if (!$data || !isset($data['email']) || !isset($data['password'])) {
            $response = $this->json([
                'error' => 'Email et mot de passe requis'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }

        $existingUser = $entityManager->getRepository(User::class)->findOneBy(['email' => $data['email']]);
        if ($existingUser) {
            $response = $this->json([
                'error' => 'Un utilisateur avec cet email existe déjà'
            ], Response::HTTP_CONFLICT);
            return $this->addCorsHeaders($response);
        }

        $user = new User();
        $user->setEmail($data['email']);
        $user->setPassword($passwordHasher->hashPassword($user, $data['password']));
        $roles = isset($data['roles']) ? $data['roles'] : ['ROLE_USER'];
        $user->setRoles($roles);

        $errors = $validator->validate($user);
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

        $entityManager->persist($user);
        $entityManager->flush();

        $response = $this->json([
            'message' => 'Utilisateur créé avec succès',
            'user' => [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'roles' => $user->getRoles()
            ]
        ], Response::HTTP_CREATED);
        return $this->addCorsHeaders($response);
    }

    #[Route('/{id}', name: 'app_users_update', methods: ['PUT', 'OPTIONS'])]
    public function update(
        Request $request,
        User $user,
        UserPasswordHasherInterface $passwordHasher,
        EntityManagerInterface $entityManager,
        ValidatorInterface $validator
    ): JsonResponse {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $data = json_decode($request->getContent(), true);
        
        if (!$data) {
            $response = $this->json([
                'error' => 'Données requises'
            ], Response::HTTP_BAD_REQUEST);
            return $this->addCorsHeaders($response);
        }

        if (isset($data['email'])) {
            $user->setEmail($data['email']);
        }

        if (isset($data['password'])) {
            $user->setPassword($passwordHasher->hashPassword($user, $data['password']));
        }

        if (isset($data['roles'])) {
            $user->setRoles($data['roles']);
        }

        $errors = $validator->validate($user);
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

        $entityManager->flush();

        $response = $this->json([
            'message' => 'Utilisateur mis à jour avec succès',
            'user' => [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'roles' => $user->getRoles()
            ]
        ]);
        return $this->addCorsHeaders($response);
    }

    #[Route('/{id}', name: 'app_users_delete', methods: ['DELETE', 'OPTIONS'])]
    public function delete(Request $request, User $user, EntityManagerInterface $entityManager): JsonResponse
    {
        // Gérer les requêtes OPTIONS (preflight)
        if ($request->getMethod() === 'OPTIONS') {
            $response = new JsonResponse();
            return $this->addCorsHeaders($response);
        }

        $entityManager->remove($user);
        $entityManager->flush();

        $response = $this->json([
            'message' => 'Utilisateur supprimé avec succès'
        ]);
        return $this->addCorsHeaders($response);
    }
}
