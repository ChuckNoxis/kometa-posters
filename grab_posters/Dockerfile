FROM python:3-alpine

# Create user and group with UID/GID 1000
RUN addgroup -g 1000 noxis && adduser -D -u 1000 -G noxis noxis

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt || true

COPY *.py .
COPY .env .

# Change ownership of all files
RUN chown -R noxis:noxis /app
# Switch to user 1000:1000
USER noxis

CMD ["python3", "grab-all-posters.py"]
