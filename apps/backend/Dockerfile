FROM python:3.9-slim AS builder

ENV PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.5 \
    POETRY_VIRTUALENVS_IN_PROJECT=true
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN pip install "poetry==${POETRY_VERSION}"

COPY poetry.lock pyproject.toml ./
RUN poetry lock --no-update && \
    poetry install --only main --no-root && \
    poetry run pip install "setuptools<81"


FROM python:3.9-slim AS runtime

ENV PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY . ./

EXPOSE 8000

CMD alembic upgrade head && uvicorn --host=0.0.0.0 app.main:app
