FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements/base.txt
CMD ["uvicorn", "services.embedding_service.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
