# ==========================================
# Stage 1: Build Context Validation
# ==========================================
FROM python:3.11-slim AS builder
WORKDIR /app
COPY . .

# ==========================================
# Stage 2: Minimalist Production Runtime
# ==========================================
FROM python:3.11-slim
WORKDIR /app

# Core runtime configurations
ENV PYTHONUNBUFFERED=1
ENV PORT=8780
ENV HERMES_HOME=/root/.hermes

# Pull repository files from builder
COPY --from=builder /app /app

EXPOSE 8780

# CRITICAL: Hard-coded binary paths to bypass OCI/runc string parsing errors
CMD ["/usr/local/bin/python", "/app/serve_lite.py"]
