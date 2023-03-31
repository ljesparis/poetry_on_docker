FROM python:3.11-alpine


ENV \
   POETRY_HOME=/poetry \
   POETRY_VIRTUALENVS_CREATE=false \
   POETRY_VERSION=1.4.0 \
   PATH="$PATH:/poetry/bin"
   

RUN apk --no-cache add curl==7.88.1-r1 && \
   rm -rf /var/cache/apk/* && \
   curl -sSL https://install.python-poetry.org | python - && \
   apk del curl


COPY . /app
WORKDIR /app

RUN poetry install

CMD [ "uvicorn", "poetry_on_docker.main:app",  "--proxy-headers", "--host", "0.0.0.0", "--port", "80" ]

