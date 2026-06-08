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

# Tell the app where the agent is mapped
ENV HERMES_HOME=/root/.hermes
ENV AGENT_DIR=/root/.hermes/hermes-agent

# Pull repository files from builder
COPY --from=builder /app /app

EXPOSE 8780

# Execute using the host's existing hermes-agent virtual environment, matching the manual start script exactly
CMD ["/root/.hermes/hermes-agent/venv/bin/python3", "/app/serve_lite.py"]
