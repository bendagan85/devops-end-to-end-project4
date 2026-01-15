# Stage 1: Build stage
FROM python:3.9-slim as builder

WORKDIR /build

# התקנת כלים זמניים אם צריך
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Final stage
FROM python:3.9-slim

WORKDIR /app

# העתקת הספריות שהותקנו מהשלב הקודם (חוסך משקל)
COPY --from=builder /root/.local /root/.local
COPY . .

# עדכון ה-PATH כדי שהפייתון יכיר בספריות שהעתקנו
ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000

CMD ["python", "main.py"]