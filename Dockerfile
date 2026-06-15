FROM python:3.11-slim
WORKDIR /app
COPY dashboard/ dashboard/
COPY serve.py start.sh ./
RUN chmod +x start.sh serve.py
EXPOSE 8888
CMD ["./start.sh"]
