import random
from rest_framework import generics, viewsets, status, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from .models import Team, Player, UserProfile, UserCard
from .serializers import TeamSerializer, PlayerSerializer, RegisterSerializer
from .serializers import UserCardSerializer
from rest_framework.permissions import AllowAny
from rest_framework.authtoken.models import Token
from django_filters.rest_framework import DjangoFilterBackend
from .models import League, UserLeague, Match, PlayerStats, TeamStats, UserLeaguePlayer
from .serializers import LeagueSerializer, UserLeagueSerializer, MatchSerializer, PlayerStatsSerializer, TeamStatsSerializer
from datetime import timedelta
from django.utils import timezone
from django.db.models import Q
from rest_framework.decorators import api_view


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            UserProfile.objects.create(user=user)  # ✅ profil yarat
            return Response({"message": "✅ User registered successfully!"}, status=status.HTTP_201_CREATED)
        print(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')  # 👈 BURASI DEĞİŞTİ
        password = request.data.get('password')

        if not username or not password:
            return Response({"error": "❌ All fields are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(username=username)  # 👈 BURASI DEĞİŞTİ
        except User.DoesNotExist:
            return Response({"error": "❌ Invalid email or password."}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):
            return Response({"error": "❌ Invalid email or password."}, status=status.HTTP_401_UNAUTHORIZED)

        # ✅ Token oluşturuluyor
        token, _ = Token.objects.get_or_create(user=user)

        return Response({
            "message": f"✅ Welcome, {user.username}!",
            "username": user.username,
            "email": user.email,
            "token": token.key  # 👈 bu satır sayesinde token frontend'e döner
        }, status=status.HTTP_200_OK)


class TeamViewSet(viewsets.ModelViewSet):
    queryset = Team.objects.all()
    serializer_class = TeamSerializer
    permission_classes = [IsAuthenticated]


class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['team']


class OpenCardPackView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        pack_name = request.data.get("pack_name")  # Frontend'den gelen paket adı

        try:
            profile = UserProfile.objects.get(user=user)
        except UserProfile.DoesNotExist:
            return Response({"error": "User profile not found."}, status=404)


        PACK_PRICES = {
            "Gold Pack": 500,
            "Amethyst Pack": 800,
            "Diamond Pack": 1000,
        }

        pack_cost = PACK_PRICES.get(pack_name)

        if pack_cost is None:
            return Response({"error": "Invalid pack name."}, status=400)

        if profile.credits < pack_cost:
            return Response({"error": "Not enough credits."}, status=400)

        # 🎯 Paket tipine göre rarity şanslarını ayarla
        rarity_weights = {
            "Gold Pack": {
                "Gold": 90,
                "Ruby": 5,
                "Amethyst": 3,
                "Diamond": 1,
                "PinkDiamond": 0.5,
                "DarkBlueDiamond": 0.5
            },
            "Amethyst Pack": {
                "Gold": 70,
                "Ruby": 15,
                "Amethyst": 8,
                "Diamond": 4,
                "PinkDiamond": 2,
                "DarkBlueDiamond": 1
            },
            "Diamond Pack": {
                    "Gold": 60,
                    "Ruby": 16,
                    "Amethyst": 10,
                    "Diamond": 8,
                    "PinkDiamond": 4,
                    "DarkBlueDiamond": 2
                },
        }

        # 🎯 Önce rarity seç
        if pack_name not in rarity_weights:
            return Response({"error": "Invalid pack type."}, status=400)

        selected_rarity = random.choices(
            population=list(rarity_weights[pack_name].keys()),
            weights=list(rarity_weights[pack_name].values()),
            k=1
        )[0]

        # 🎯 Seçilen rarity'e göre oyunculardan rastgele seç
        players_of_selected_rarity = Player.objects.filter(rarity=selected_rarity)

        if not players_of_selected_rarity.exists():
            players_of_selected_rarity = Player.objects.filter(rarity="Gold")
            if not players_of_selected_rarity.exists():
                return Response({"error": "No players available in database."}, status=404)

        selected_player = random.choice(players_of_selected_rarity)

        profile.credits -= pack_cost
        profile.save()

        UserCard.objects.create(user=user, player=selected_player)


        return Response({
            "message": "Card opened!",
            "player": PlayerSerializer(selected_player).data,
            "new_credits": profile.credits
        }, status=200)


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            profile = UserProfile.objects.get(user=request.user)
            return Response({
                "username": request.user.username,
                "credits": profile.credits
            })
        except UserProfile.DoesNotExist:
            return Response({"error": "User profile not found."}, status=404)


class MyCardsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_cards = UserCard.objects.filter(user=request.user).select_related('player')
        serializer = UserCardSerializer(user_cards, many=True)
        return Response(serializer.data)




# ✅ 1. Aktif Ligleri Listeleme
class LeagueListView(generics.ListAPIView):
    queryset = League.objects.filter(active=True)
    serializer_class = LeagueSerializer
    permission_classes = [IsAuthenticated]

class JoinLeagueView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        league_id = request.data.get('league_id')
        player_ids = request.data.get('player_ids', [])
        starting_five_ids = request.data.get('starting_five_ids', [])

        if not league_id:
            return Response({"error": "League ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        if not player_ids or len(player_ids) != 10:
            return Response({"error": "You must select exactly 10 players."}, status=status.HTTP_400_BAD_REQUEST)

        if not starting_five_ids or len(starting_five_ids) != 5:
            return Response({"error": "You must select exactly 5 players for starting five."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            league = League.objects.get(id=league_id)
        except League.DoesNotExist:
            return Response({"error": "League not found"}, status=status.HTTP_404_NOT_FOUND)

        if UserLeague.objects.filter(user=request.user, league=league).exists():
            return Response({"error": "Already joined this league"}, status=status.HTTP_400_BAD_REQUEST)

        if UserLeague.objects.filter(league=league).count() >= league.max_players:
            return Response({"error": "League is full"}, status=status.HTTP_400_BAD_REQUEST)

        # Kullanıcı ligi kayıt et
        user_league = UserLeague.objects.create(user=request.user, league=league)

        # Seçilen 10 oyuncuyu kaydet
        for player_id in player_ids:
            is_starting = player_id in starting_five_ids
            try:
                player = Player.objects.get(id=player_id)
            except Player.DoesNotExist:
                continue

            UserLeaguePlayer.objects.create(
                user_league=user_league,
                player=player,
                is_starting_five=is_starting
            )

        return Response({"message": "Successfully joined the league and created team!"}, status=status.HTTP_201_CREATED)

# ✅ 3. Kullanıcının Kendi Ligini Görmesi
class MyLeagueView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            user_league = UserLeague.objects.get(user=request.user)
            serializer = LeagueSerializer(user_league.league)
            return Response(serializer.data)
        except UserLeague.DoesNotExist:
            return Response({"error": "Not joined in any league"}, status=404)


# ✅ 4. Lig Dolduğunda Maç Programı Oluştur
class CreateMatchScheduleView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            user_league = UserLeague.objects.get(user=request.user)
            league = user_league.league
        except UserLeague.DoesNotExist:
            return Response({"error": "Not in any league"}, status=400)

        participants = UserLeague.objects.filter(league=league).values_list('user', flat=True)

        if len(participants) < league.max_players:
            return Response({"error": "League is not full yet"}, status=400)

        participants = list(participants)

        # Her oyuncu diğer tüm oyuncularla oynamalı
        match_days = 9
        scheduled_times = ['morning', 'afternoon', 'evening']
        current_date = timezone.now().date()

        matches_created = []

        all_matches = []
        for i in range(len(participants)):
            for j in range(i + 1, len(participants)):
                all_matches.append((participants[i], participants[j]))

        for idx, (player1, player2) in enumerate(all_matches):
            match = Match.objects.create(
                player1_id=player1,
                player2_id=player2,
                league=league,
                date=current_date + timedelta(days=idx // 3),
                scheduled_time=scheduled_times[idx % 3],
                status='pending'
            )

            matches_created.append(match.id)

        return Response({"message": "Match schedule created", "matches": matches_created}, status=200)


# ✅ 5. Kullanıcının Maç Takvimini Getir
class MatchScheduleView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        matches = Match.objects.filter(player1=request.user) | Match.objects.filter(player2=request.user)
        serializer = MatchSerializer(matches, many=True)
        return Response(serializer.data)


# ✅ 6. Maç Sonucunu Kaydet
class RecordMatchResultView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        match_id = request.data.get('match_id')
        score1 = request.data.get('score1')
        score2 = request.data.get('score2')

        try:
            match = Match.objects.get(id=match_id)
        except Match.DoesNotExist:
            return Response({"error": "Match not found"}, status=404)

        if match.status == 'finished':
            return Response({"error": "Match already finished"}, status=400)

        match.score1 = score1
        match.score2 = score2

        if score1 > score2:
            match.winner = match.player1
        elif score2 > score1:
            match.winner = match.player2
        else:
            match.winner = None  # İstersen berabere bırakabilirsin

        match.status = 'finished'
        match.save()

        # İstatistik ekle (isteğe bağlı geliştirebiliriz)
        PlayerStats.objects.create(player=match.player1, match=match, points=score1)
        PlayerStats.objects.create(player=match.player2, match=match, points=score2)

        return Response({"message": "Match result recorded"}, status=200)


# ✅ 7. Lig Puan Tablosu
class LeagueStandingsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            user_league = UserLeague.objects.get(user=request.user)
            league = user_league.league
        except UserLeague.DoesNotExist:
            return Response({"error": "Not joined in any league"}, status=400)

        players = UserLeague.objects.filter(league=league).values_list('user', flat=True)

        standings = []

        for player_id in players:
            player = User.objects.get(id=player_id)
            matches_played = Match.objects.filter(
                (Q(player1=player) | Q(player2=player)),
                league=league,
                status='finished'
            )
            wins = matches_played.filter(winner=player).count()
            losses = matches_played.exclude(winner=player).count()

            standings.append({
                "player_id": player.id,
                "username": player.username,
                "wins": wins,
                "losses": losses,
                "points": wins * 3  # 3 puanlı sistem
            })

        # Puanlara göre sıralama
        standings = sorted(standings, key=lambda x: (-x['points'], x['losses']))

        return Response(standings)




@api_view(['GET'])  # ← GET olarak açıyoruz ki tarayıcıdan girilebilsin
def start_league_manual(request, league_id):
    try:
        league = League.objects.get(id=league_id)

        if league.status == 'finished':
            return Response({"error": "League already finished."}, status=400)

        user_leagues = UserLeague.objects.filter(league=league)
        players = [ul.user for ul in user_leagues]

        # Her oyuncu her oyuncuyla 1 maç yapacak
        match_time = timezone.now()
        matches = []
        for i in range(len(players)):
            for j in range(i + 1, len(players)):
                match = Match(
                    league=league,
                    player1=players[i],
                    player2=players[j],
                    date=match_time.date(),
                    scheduled_time='morning',
                    status='pending'
                )

                matches.append(match)
                match_time += timedelta(hours=8)  # 8 saat arayla
        Match.objects.bulk_create(matches)

        league.status = 'ongoing'
        league.save()

        return Response({"message": "League matches created successfully."})

    except League.DoesNotExist:
        return Response({"error": "League not found"}, status=404)