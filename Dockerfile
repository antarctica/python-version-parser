FROM python:3.8-alpine as base

LABEL maintainer = "Felix Fennell <felnne@bas.ac.uk>"

ENV APPPATH=/usr/src/app/
ENV PYTHONPATH=$APPPATH

RUN mkdir $APPPATH
WORKDIR $APPPATH

RUN apk add --no-cache libxslt-dev libffi-dev libressl-dev git


FROM base as build

ENV APPVENV=/usr/local/virtualenvs/python_version_parser

RUN apk add --no-cache build-base
RUN python3 -m venv $APPVENV
ENV PATH="$APPVENV/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir poetry==1.0.0

COPY pyproject.toml poetry.toml poetry.lock $APPPATH
RUN poetry install --no-root --no-interaction --no-ansi

FROM base as run

ENV APPPATH=/usr/src/app/
ENV APPVENV=/usr/local/virtualenvs/python_version_parser
ENV PATH="$APPVENV/bin:$PATH"

COPY --from=build $APPVENV/ $APPVENV/
COPY entrypoint.sh $APPPATH/
COPY python_version_parser/ $APPPATH/python_version_parser/

ENTRYPOINT ["ash"]
CMD [ "/usr/src/app/entrypoint.sh" ]
