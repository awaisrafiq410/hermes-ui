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
ENV HERMES_HOME=/mnt/hdd_500gb/DATA/AppData/.hermes
ENV AGENT_DIR=/mnt/hdd_500gb/DATA/AppData/hermes-agent

# Pull repository files from builder
COPY --from=builder /app /app

# Patch serve_lite.py to respect HERMES_HOME and AGENT_DIR environment variables instead of hardcoding ~/.hermes
RUN sed -i 's|HERMES_HOME = os.path.expanduser("~/.hermes")|HERMES_HOME = os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))|g' /app/serve_lite.py \
    && sed -i 's|AGENT_DIR = os.path.join(DEFAULT_HERMES_HOME, "hermes-agent")|AGENT_DIR = os.environ.get("AGENT_DIR", os.path.join(DEFAULT_HERMES_HOME, "hermes-agent"))|g' /app/serve_lite.py

EXPOSE 8780

# CRITICAL: Hard-coded binary paths to bypass OCI/runc string parsing errors
CMD ["/usr/local/bin/python", "/app/serve_lite.py"]
