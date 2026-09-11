FROM python:3.12-slim

WORKDIR /app

# Принимаем DEPLOY_REF как build-arg и зашиваем в ENV образа
ARG DEPLOY_REF=unknown
ENV DEPLOY_REF=$DEPLOY_REF

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/
COPY static/ ./static/
COPY templates/ ./templates/
COPY config.json .

EXPOSE 8181

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8181"]
