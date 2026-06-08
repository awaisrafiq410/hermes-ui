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

# Install git to clone hermes-agent
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone and install the underlying hermes-agent (required by serve_lite.py for chat)
RUN git clone https://github.com/pyrate-llama/hermes-agent.git /app/hermes-agent \
    && pip install --no-cache-dir -e /app/hermes-agent

# Core runtime configurations
ENV PYTHONUNBUFFERED=1
ENV PORT=8780
ENV HERMES_HOME=/root/.hermes

# Pull repository files from builder
COPY --from=builder /app /app

# Patch serve_lite.py to look for hermes-agent in /app/hermes-agent instead of /root/.hermes
RUN sed -i 's|AGENT_DIR = os.path.join(DEFAULT_HERMES_HOME, "hermes-agent")|AGENT_DIR = "/app/hermes-agent"|g' /app/serve_lite.py

EXPOSE 8780

# CRITICAL: Hard-coded binary paths to bypass OCI/runc string parsing errors
CMD ["/usr/local/bin/python", "/app/serve_lite.py"]
