from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.urls import include
from .views import TeamViewSet, PlayerViewSet
from .views import RegisterView, LoginView

# Root endpoint için bir API view
@api_view(['GET'])
def api_root(request):
    return Response({
        "teams": "/api/teams/",
        "players": "/api/players/",
        "register": "/api/register/",
        "login": "/api/login/",
    })

# DefaultRouter ile viewsetleri ekliyoruz
router = DefaultRouter()
router.register('teams', TeamViewSet, basename='team')
router.register('players', PlayerViewSet, basename='player')

urlpatterns = [
    path('', api_root, name='api-root'),  # Root endpoint
    path('', include(router.urls)),  # DefaultRouter'ı dahil et
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
]

