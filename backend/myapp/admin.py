from django.contrib import admin
from django import forms
from django.contrib.auth.models import User
from .models import Team, Player, UserCard, UserProfile
from .models import League, UserLeague, Match, PlayerStats, TeamStats, UserLeaguePlayer

# UserLeaguePlayer için form
class UserLeaguePlayerForm(forms.ModelForm):
    class Meta:
        model = UserLeaguePlayer
        fields = '__all__'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if 'team' in self.data:
            try:
                team_id = int(self.data.get('team'))
                team = UserLeague.objects.get(id=team_id)
                user = team.user
                owned_players = UserCard.objects.filter(user=user).values_list('player', flat=True)
                self.fields['player'].queryset = Player.objects.filter(id__in=owned_players)
            except (ValueError, TypeError, UserLeague.DoesNotExist):
                self.fields['player'].queryset = Player.objects.none()
        elif self.instance.pk:
            user = self.instance.team.user
            owned_players = UserCard.objects.filter(user=user).values_list('player', flat=True)
            self.fields['player'].queryset = Player.objects.filter(id__in=owned_players)
        else:
            self.fields['player'].queryset = Player.objects.none()

# Normal admin kayıtları
@admin.register(UserCard)
class UserCardAdmin(admin.ModelAdmin):
    list_display = ('user', 'player', 'acquired_at')
    list_filter = ('user', 'acquired_at')
    search_fields = ('user__username', 'player__name')

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'credits')
    search_fields = ('user__username',)

@admin.register(Team)
class TeamAdmin(admin.ModelAdmin):
    list_display = ('name', 'city', 'established_year', 'arena_name')
    search_fields = ('name', 'city')


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ('name', 'team', 'position', 'age', 'profile_picture', 'rarity')
    list_filter = ('team', 'position', 'nationality', 'rarity')
    search_fields = ('name', 'team__name')

    def save_model(self, request, obj, form, change):
        if obj.overall_rating is not None:
            if obj.overall_rating >= 95:
                obj.rarity = "DarkBlueDiamond"
            elif obj.overall_rating >= 90:
                obj.rarity = "PinkDiamond"
            elif obj.overall_rating >= 85:
                obj.rarity = "Diamond"
            elif obj.overall_rating >= 80:
                obj.rarity = "Amethyst"
            elif obj.overall_rating >= 75:
                obj.rarity = "Ruby"
            else:
                obj.rarity = "Gold"
        obj.save()


@admin.register(League)
class LeagueAdmin(admin.ModelAdmin):
    list_display = ('name', 'start_date', 'end_date', 'max_players', 'active', 'current_day')
    search_fields = ('name',)
    list_filter = ('active',)

@admin.register(UserLeague)
class UserLeagueAdmin(admin.ModelAdmin):
    list_display = ('user', 'league', 'joined_at')
    search_fields = ('user__username', 'league__name')
    list_filter = ('league',)

@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ('player1', 'player2', 'winner', 'league', 'date', 'scheduled_time', 'status')
    search_fields = ('player1__username', 'player2__username', 'winner__username')
    list_filter = ('league', 'status', 'scheduled_time')

@admin.register(PlayerStats)
class PlayerStatsAdmin(admin.ModelAdmin):
    list_display = ('player', 'match', 'points', 'rebounds', 'assists')
    search_fields = ('player__username',)

@admin.register(TeamStats)
class TeamStatsAdmin(admin.ModelAdmin):
    list_display = ('get_username', 'get_league_name', 'wins', 'losses', 'total_points')
    search_fields = ('user_league__user__username', 'league__name')

    def get_username(self, obj):
        return obj.user_league.user.username
    get_username.short_description = 'Username'

    def get_league_name(self, obj):
        return obj.league.name
    get_league_name.short_description = 'League'



@admin.register(UserLeaguePlayer)
class UserLeaguePlayerAdmin(admin.ModelAdmin):
    form = UserLeaguePlayerForm
    list_display = ('get_user', 'get_league', 'get_player_with_overall', 'is_starting_five')
    list_filter = ('is_starting_five',)
    search_fields = ('player__name', 'team__user__username')
    ordering = ('team__user__username', 'team__league__name')

    def get_user(self, obj):
        return obj.team.user.username
    get_user.short_description = 'User'

    def get_league(self, obj):
        return obj.team.league.name
    get_league.short_description = 'League'

    def get_player_with_overall(self, obj):
        return f"{obj.player.name} (Overall: {obj.player.overall_rating})"
    get_player_with_overall.short_description = 'Player (Overall)'
