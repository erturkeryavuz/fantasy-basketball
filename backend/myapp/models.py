from django.db import models
from django.contrib.auth.models import User

class Team(models.Model):
    name = models.CharField(max_length=100)
    city = models.CharField(max_length=100)
    established_year = models.IntegerField()
    logo = models.ImageField(upload_to='team_logos/')
    arena_name = models.CharField(max_length=100, blank=True, null=True)  # Oynanan salonun adı

    def __str__(self):
        return self.name



class Player(models.Model):
    name = models.CharField(max_length=100)
    team = models.ForeignKey('Team', on_delete=models.CASCADE, related_name="players")
    position = models.CharField(max_length=50)
    age = models.IntegerField()
    height = models.IntegerField(blank=True, null=True)
    weight = models.IntegerField(blank=True, null=True)
    overall_rating = models.IntegerField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='player_pictures/', null=True, blank=True)  # Değişiklik burada
    bio = models.TextField(blank=True, null=True)  # Kısa biyografi
    experience_years = models.IntegerField(blank=True, null=True)  # Lig tecrübesi
    nationality = models.CharField(max_length=50, blank=True, null=True)  # Uyruğu
    best_skill = models.CharField(max_length=50, null=True, blank=True)
    RARITY_CHOICES = [
        ('DarkBlueDiamond', 'Dark Blue Diamond'),
        ('PinkDiamond', 'Pink Diamond'),
        ('Diamond', 'Diamond'),
        ('Amethyst', 'Amethyst'),
        ('Ruby', 'Ruby'),
        ('Gold', 'Gold'),
    ]

    rarity = models.CharField(max_length=50, choices=RARITY_CHOICES, default='Gold')

    def save(self, *args, **kwargs):
        if self.overall_rating is not None:
            if self.overall_rating >= 95:
                self.rarity = "DarkBlueDiamond"
            elif self.overall_rating >= 90:
                self.rarity = "PinkDiamond"
            elif self.overall_rating >= 85:
                self.rarity = "Diamond"
            elif self.overall_rating >= 80:
                self.rarity = "Amethyst"
            elif self.overall_rating >= 75:
                self.rarity = "Ruby"
            else:
                self.rarity = "Gold"
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name




class UserCard(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="cards")
    player = models.ForeignKey("Player", on_delete=models.CASCADE)
    acquired_at = models.DateTimeField(auto_now_add=True)



# models.py
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    credits = models.IntegerField(default=1000)  # Başlangıç kredisi

    def __str__(self):
        return f"{self.user.username} Profile"

class League(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    max_players = models.IntegerField(default=10)  # 10 kişi dolunca lig başlasın
    active = models.BooleanField(default=True)
    current_day = models.IntegerField(default=1)  # Lig günü (1. gün, 2. gün gibi takip)
    status = models.CharField(max_length=20, choices=[('pending', 'Pending'), ('in_progress', 'In Progress'),
                                                      ('finished', 'Finished')], default='pending')




    def __str__(self):
        return self.name

class UserLeague(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    league = models.ForeignKey(League, on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} in {self.league.name}"

class Match(models.Model):
    player1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='player1_matches')
    player2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='player2_matches')
    winner = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, related_name='won_matches')
    league = models.ForeignKey(League, on_delete=models.CASCADE)
    date = models.DateField()
    scheduled_time = models.CharField(max_length=20, choices=[('morning', 'Morning'), ('afternoon', 'Afternoon'), ('evening', 'Evening')])
    score1 = models.IntegerField(null=True, blank=True)
    score2 = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=[('pending', 'Pending'), ('finished', 'Finished')], default='pending')

    def __str__(self):
        return f"Match: {self.player1.username} vs {self.player2.username}"

class PlayerStats(models.Model):
    player = models.ForeignKey(User, on_delete=models.CASCADE)
    match = models.ForeignKey(Match, on_delete=models.CASCADE)
    points = models.IntegerField(default=0)
    rebounds = models.IntegerField(default=0)
    assists = models.IntegerField(default=0)

    class Meta:
        verbose_name_plural = "Player Stats"

    def __str__(self):
        return f"Stats for {self.player.username} in match {self.match.id}"

class TeamStats(models.Model):
    user_league = models.ForeignKey('UserLeague', on_delete=models.CASCADE)
    league = models.ForeignKey(League, on_delete=models.CASCADE)
    wins = models.IntegerField(default=0)
    losses = models.IntegerField(default=0)
    total_points = models.IntegerField(default=0)

    class Meta:
        verbose_name_plural = "Team Stats"

    def __str__(self):
        return f"TeamStats: {self.user_league.user.username} in {self.league.name}"



class UserLeaguePlayer(models.Model):
    team = models.ForeignKey(UserLeague, on_delete=models.CASCADE, related_name='players')
    player = models.ForeignKey(Player, on_delete=models.CASCADE)
    is_starting_five = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.player.name} ({'Starting Five' if self.is_starting_five else 'Bench'})"

