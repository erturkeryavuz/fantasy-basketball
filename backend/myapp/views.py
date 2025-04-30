from rest_framework import generics, viewsets
from .models import Team, Player
from .serializers import TeamSerializer, PlayerSerializer, RegisterSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.contrib.auth import authenticate

class RegisterView(APIView):

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "✅ User registered successfully!"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response({"error": "❌ All fields are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(email=email)  # Email ile kullanıcıyı bul
        except User.DoesNotExist:
            return Response({"error": "❌ Invalid email or password."}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):  # Şifreyi kontrol et
            return Response({"error": "❌ Invalid email or password."}, status=status.HTTP_401_UNAUTHORIZED)

        return Response({
            "message": f"✅ Welcome, {user.username}!",
            "username": user.username,
            "email": user.email
        }, status=status.HTTP_200_OK)


class TeamViewSet(viewsets.ModelViewSet):
    queryset = Team.objects.all()
    serializer_class = TeamSerializer


class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer
