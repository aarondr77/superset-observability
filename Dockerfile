FROM python:3.11-slim
WORKDIR /app
COPY dashboard/ dashboard/
EXPOSE 8888
CMD ["python", "-m", "http.server", "8888", "--directory", "dashboard"]
