FROM python:3.11-alpine as builder

ENV \
   POETRY_HOME=/poetry \
   POETRY_VIRTUALENVS_CREATE=false \
   POETRY_VERSION=1.4.0 \
   PATH="$PATH:/poetry/bin"

# https://github.com/hadolint/hadolint/issues/250#issuecomment-409891140
SHELL [ "/bin/ash", "-eo", "pipefail", "-c" ]

RUN apk --no-cache add curl==7.88.1-r1 && \
   curl -sSL https://install.python-poetry.org | python -

COPY . /app
WORKDIR /app
RUN poetry install 


# final image that doesn't need poetry and curl 
FROM python:3.11-alpine

WORKDIR /app

COPY --from=builder /app/ /app/
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn
COPY --from=builder /usr/local/bin/watchfiles /usr/local/bin/watchfiles

CMD [ "uvicorn", "poetry_on_docker.main:app",  "--proxy-headers", "--host", "0.0.0.0", "--port", "80" ]

