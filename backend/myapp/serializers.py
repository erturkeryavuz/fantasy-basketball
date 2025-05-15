from rest_framework import serializers
from .models import Player, Team
from django.contrib.auth.models import User
from .models import UserCard
import re
from .models import League, UserLeague, Match, PlayerStats, TeamStats


class RegisterSerializer(serializers.ModelSerializer):
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def validate_email(self, value):

        email_regex = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$"
        allowed_domains = ["gmail.com", "yahoo.com", "outlook.com"]

        if not re.match(email_regex, value):
            raise serializers.ValidationError("❌ Invalid email format.")

        domain = value.split('@')[-1]
        if domain not in allowed_domains:
            raise serializers.ValidationError(
                f"❌ Email domain must be one of the following: {', '.join(allowed_domains)}."
            )

        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("❌ This email is already registered.")

        return value

    def validate_username(self, value):

        if len(value) < 3:
            raise serializers.ValidationError("❌ Username must be at least 3 characters long.")
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("❌ Username already exists.")
        return value

    def validate_password(self, value):

        if len(value) < 8:
            raise serializers.ValidationError("❌ Password must be at least 8 characters long.")
        if not any(char.isdigit() for char in value):
            raise serializers.ValidationError("❌ Password must include at least one number.")
        if not any(char.isalpha() for char in value):
            raise serializers.ValidationError("❌ Password must include at least one letter.")
        return value

    def create(self, validated_data):

        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user


class TeamSerializer(serializers.ModelSerializer):
    class Meta:
        model = Team
        fields = [
            'id',
            'name',
            'city',
            'established_year',
            'logo',
            'arena_name'
        ]



class PlayerSerializer(serializers.ModelSerializer):
    team_name = serializers.CharField(source='team.name', read_only=True)
    rarity = serializers.CharField(read_only=True)

    POSITION_CHOICES = [
        ('Guard', 'Guard'),
        ('Forward', 'Forward'),
        ('Center', 'Center'),
    ]

    NATIONALITY_CHOICES = [
        ('USA', 'USA'),
        ('France', 'France'),
        ('Spain', 'Spain'),
        ('Turkey', 'Turkey'),
        ('Canada', 'Canada'),
        ('Germany', 'Germany'),
        ('Serbia','Serbia'),
    ]

    BEST_SKILL_CHOICES = [
        ('shooting', 'Shooting'),
        ('passing', 'Passing'),
        ('defense', 'Defense'),
        ('rebounding', 'Rebounding'),
        ('speed', 'Speed'),
        ('athleticism', 'Athleticism'),
        ('three_point_shooting', 'Three Point Shooting'),
        ('mid_range_shooting', 'Mid Range Shooting'),
        ('free_throw_shooting', 'Free Throw Shooting'),
        ('court_vision', 'Court Vision'),
        ('playmaking', 'Playmaking'),
        ('leadership', 'Leadership'),
        ('clutch', 'Clutch')
    ]

    best_skill = serializers.ChoiceField(choices=BEST_SKILL_CHOICES)
    position = serializers.ChoiceField(choices=POSITION_CHOICES)
    nationality = serializers.ChoiceField(choices=NATIONALITY_CHOICES)
    age = serializers.IntegerField(min_value=16, max_value=45)
    height = serializers.IntegerField(min_value=150, max_value=230)
    weight = serializers.IntegerField(min_value=50, max_value=140)
    overall_rating = serializers.IntegerField(min_value=55, max_value=99)
    experience_years = serializers.IntegerField(min_value=0, max_value=25)

    class Meta:
        model = Player
        fields = [
            'id',
            'name',
            'team',
            'team_name',
            'position',
            'age',
            'height',
            'weight',
            'profile_picture',
            'bio',
            'experience_years',
            'nationality',
            'overall_rating',
            'best_skill',
            'rarity',  # 👈 EKLENECEK
        ]

class UserCardSerializer(serializers.ModelSerializer):
    player_name = serializers.CharField(source='player.name', read_only=True)
    overall_rating = serializers.IntegerField(source='player.overall_rating', read_only=True)
    rarity = serializers.CharField(source='player.rarity', read_only=True)  # 👈 rarity eklendi
    acquired_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = UserCard
        fields = ['player_name', 'overall_rating', 'rarity', 'acquired_at']




class LeagueSerializer(serializers.ModelSerializer):
    class Meta:
        model = League
        fields = '__all__'

class UserLeagueSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserLeague
        fields = '__all__'

class MatchSerializer(serializers.ModelSerializer):
    player1_username = serializers.CharField(source='player1.username', read_only=True)
    player2_username = serializers.CharField(source='player2.username', read_only=True)
    winner_username = serializers.CharField(source='winner.username', read_only=True)

    class Meta:
        model = Match
        fields = [
            'id', 'player1', 'player1_username', 'player2', 'player2_username',
            'winner', 'winner_username', 'league', 'date', 'scheduled_time',
            'score1', 'score2', 'status'
        ]

class PlayerStatsSerializer(serializers.ModelSerializer):
    player_username = serializers.CharField(source='player.username', read_only=True)

    class Meta:
        model = PlayerStats
        fields = ['id', 'player', 'player_username', 'match', 'points', 'rebounds', 'assists']

class TeamStatsSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user_league.user.username', read_only=True)
    league_name = serializers.CharField(source='league.name', read_only=True)

    class Meta:
        model = TeamStats
        fields = [
            'id',
            'username',
            'league_name',
            'wins',
            'losses',
            'total_points'
        ]
