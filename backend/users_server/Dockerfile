FROM --platform=$TARGETPLATFORM python:3.13-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/build_app

RUN python -m pip install --no-cache-dir --upgrade pip wheel

COPY requirements.txt .

RUN python -m venv /opt/venv && . /opt/venv/bin/activate && pip install --no-cache-dir -r requirements.txt && pip install --no-cache-dir gunicorn

COPY . /opt/build_app/app_code/

WORKDIR /opt/build_app/app_code/

RUN . /opt/venv/bin/activate && SECRET_KEY="dummy-secret-key-for-build-only-not-for-prod" python manage.py collectstatic --noinput --clear

FROM --platform=$TARGETPLATFORM python:3.13-slim AS final

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd --system appuser && useradd --system --gid appuser --no-create-home appuser

COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appuser --from=builder /opt/build_app/app_code /app

USER appuser

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

EXPOSE 8001

CMD ["gunicorn", "server.wsgi:application", "--bind", "0.0.0.0:8001", "--workers", "3"]