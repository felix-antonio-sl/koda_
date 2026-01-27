# KODA Runtime Dockerfile
# Base environment for running KODA agents in production

FROM python:3.11-slim-bookworm

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    KODA_HOME="/opt/koda" \
    PATH="/opt/koda/scripts:${PATH}"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    # Required for some python extensions
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create koda user and directories
RUN groupadd -r koda && useradd -r -g koda -s /bin/bash -d /opt/koda koda && \
    mkdir -p /opt/koda/repos && \
    mkdir -p /opt/koda/data && \
    chown -R koda:koda /opt/koda

# Working directory
WORKDIR /opt/koda

# Switch to non-root user
USER koda

# Copy scripts (CLI tools)
COPY --chown=koda:koda scripts/ /opt/koda/scripts/

# Make scripts executable
RUN chmod +x /opt/koda/scripts/*

# Entrypoint script
COPY --chown=koda:koda infrastructure/scripts/entrypoint.sh /opt/koda/entrypoint.sh
RUN chmod +x /opt/koda/entrypoint.sh

# Expose port (if needed for API)
EXPOSE 8000

# Default command
ENTRYPOINT ["/opt/koda/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
