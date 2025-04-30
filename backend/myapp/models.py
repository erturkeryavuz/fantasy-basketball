from django.db import models

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
    height = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)  # Boy (metre)
    weight = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)  # Kilo (kg)
    profile_picture = models.ImageField(upload_to='player_pictures/', null=True, blank=True)  # Değişiklik burada
    bio = models.TextField(blank=True, null=True)  # Kısa biyografi
    experience_years = models.IntegerField(blank=True, null=True)  # Lig tecrübesi
    nationality = models.CharField(max_length=50, blank=True, null=True)  # Uyruğu
    overall_rating = models.DecimalField(max_digits=4, decimal_places=2, blank=True, null=True)  # Genel yetenek puanı
    best_skill = models.CharField(max_length=50, null=True, blank=True)

    def __str__(self):
        return self.name
