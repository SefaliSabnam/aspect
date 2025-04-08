FROM python:3.9
WORKDIR /app
COPY backend/ .         # Copy backend code
COPY frontend/templates ./templates
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
