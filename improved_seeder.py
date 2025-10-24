import os
import django
from faker import Faker
from treasures.models import Treasures
import random
import math

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'your_project.settings')
django.setup()

def generate_nearby_coordinates(base_lat, base_lng, max_distance_km=50):
    """
    Genera coordenadas aleatorias dentro de un radio máximo desde una ubicación base.
    """
    # Convertir km a grados (aproximadamente)
    max_distance_degrees = max_distance_km / 111.32  # 1 grado ≈ 111.32 km

    # Generar ángulo y distancia aleatorios
    angle = random.uniform(0, 2 * math.pi)
    distance = random.uniform(0, max_distance_degrees)

    # Calcular nuevas coordenadas
    delta_lat = distance * math.cos(angle)
    delta_lng = distance * math.sin(angle) / math.cos(math.radians(base_lat))

    new_lat = base_lat + delta_lat
    new_lng = base_lng + delta_lng

    return new_lat, new_lng

def generate_treasure(i, base_lat=4.7110, base_lng=-74.0721, max_radius_km=50):
    """
    Genera un tesoro con coordenadas cercanas a Bogotá.
    """
    fake = Faker('es_ES')

    # Generar coordenadas cercanas a Bogotá
    latitude, longitude = generate_nearby_coordinates(base_lat, base_lng, max_radius_km)

    is_found = fake.boolean(chance_of_getting_true=30)  # 30% de probabilidad de ser encontrado

    return Treasures(
        creator_id=fake.uuid4(),
        creator_name=fake.name(),
        title=fake.sentence(nb_words=4),
        # Usar coordenadas GeoJSON correctas
        location={"type": "Point", "coordinates": [longitude, latitude]},
        description=fake.text(max_nb_chars=200),
        image_url=fake.image_url(),
        latitude=str(latitude),
        longitude=str(longitude),
        hint=fake.sentence(nb_words=6),
        difficulty=fake.random_int(min=1, max=5),
        clues=[fake.sentence(nb_words=5) for _ in range(fake.random_int(min=1, max=5))],
        # Si no está encontrado, found_by y found_at deben ser None
        is_found=is_found,
        found_by=fake.uuid4() if is_found else None,
        created_at=fake.date_time_this_decade(),
        found_at=fake.date_time_this_year() if is_found else None,
        points=fake.random_int(min=1, max=100)
    ).save()

# Generar 20 tesoros cercanos a Bogotá
if __name__ == "__main__":
    print("Generando tesoros cercanos a Bogotá...")
    for i in range(20):
        try:
            treasure = generate_treasure(i)
            print(f"Tesoro {i+1} creado: {treasure.title}")
        except Exception as e:
            print(f"Error creando tesoro {i+1}: {e}")

    print("¡Seeder completado!")