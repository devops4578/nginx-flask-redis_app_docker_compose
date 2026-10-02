FROM python:3.6-slim

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir "setuptools<46.0.0" && pip install --no-cache-dir -r requirements.txt

COPY app.py /app/

ENTRYPOINT ["python3", "app.py"]