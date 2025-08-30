#!/bin/sh

# Run migrations
echo "Running migrations..."
python sandbox/manage.py migrate

# Wait a moment for migrations to complete
sleep 2

# Create dummy data
echo "Creating dummy data..."
python sandbox/manage.py createdummydata

# Create superuser if it doesn't exist
echo "Creating superuser..."
python sandbox/manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
email = "${DJANGO_SUPERUSER_EMAIL}"
if not User.objects.filter(email=email).exists():
    user = User.objects.create_superuser(
        email="${DJANGO_SUPERUSER_EMAIL}",
        password="${DJANGO_SUPERUSER_PASSWORD}"
    )
    print(f"Superuser created successfully: {user.email}")
else:
    print(f"Superuser already exists: {email}")
END

# Execute the CMD from Dockerfile (start server)
echo "Starting Django server..."
exec "$@"
