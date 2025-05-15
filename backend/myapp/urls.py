from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .views import TeamViewSet, PlayerViewSet, RegisterView, LoginView, OpenCardPackView
from .views import UserProfileView
from .views import MyCardsView
from rest_framework.authtoken.views import obtain_auth_token
from .views import (
    LeagueListView,
    JoinLeagueView,
    MyLeagueView,
    CreateMatchScheduleView,
    MatchScheduleView,
    RecordMatchResultView,
    LeagueStandingsView
)
from .views import start_league_manual

@api_view(['GET'])
def api_root(request):
    return Response({
        "teams": "/api/teams/",
        "players": "/api/players/",
        "register": "/api/register/",
        "login": "/api/login/",
        "open_pack": "/api/open-pack/",
        "profile": "/api/profile/"

    })

router = DefaultRouter()
router.register('teams', TeamViewSet, basename='team')
router.register('players', PlayerViewSet, basename='player')

urlpatterns = [
    path('open-pack/', OpenCardPackView.as_view(), name='open-pack'),
    path('', api_root, name='api-root'),
    path('', include(router.urls)),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('my-cards/', MyCardsView.as_view(), name='my-cards'),
    path('token-login/', obtain_auth_token, name='token-login'),
    path('leagues/', LeagueListView.as_view(), name='league-list'),
    path('join-league/', JoinLeagueView.as_view(), name='join-league'),
    path('my-league/', MyLeagueView.as_view(), name='my-league'),
    path('create-schedule/', CreateMatchScheduleView.as_view(), name='create-schedule'),
    path('match-schedule/', MatchScheduleView.as_view(), name='match-schedule'),
    path('record-match/', RecordMatchResultView.as_view(), name='record-match'),
    path('standings/', LeagueStandingsView.as_view(), name='league-standings'),
    path('start-league-manual/<int:league_id>/', start_league_manual, name='start-league-manual'),  # GET için

]
