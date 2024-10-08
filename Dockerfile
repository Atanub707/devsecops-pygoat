# Use a more recent and stable base image
FROM python:3.11-slim-bullseye

# Set the working directory inside the container
WORKDIR /app

# Install necessary system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    build-essential \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Upgrade pip to the latest version
RUN python -m pip install --no-cache-dir --upgrade pip

# Install Python package dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the project files to the container
COPY . /app/

# Expose the application port
EXPOSE 8000

# Run database migrations
RUN python3 /app/manage.py migrate

# Set the working directory for the application
WORKDIR /app/pygoat/

# Command to run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
