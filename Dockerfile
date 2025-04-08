FROM python:3.9-slim

WORKDIR /app

# Copy backend files (app.py, requirements.txt)
COPY backend/ /app/

# Copy frontend index.html into the Flask templates folder
COPY frontend/index.html /app/templates/

# Install Python dependencies
RUN pip install -r requirements.txt

# Run the Flask app
CMD ["python", "app.py"]
