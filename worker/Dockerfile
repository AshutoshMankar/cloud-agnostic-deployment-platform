FROM python:3.12-alpine

ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --no-cache-dir redis==5.2.1

COPY worker.py /app/worker.py

CMD ["python", "/app/worker.py"]
