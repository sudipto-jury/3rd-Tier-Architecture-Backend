# ================================
# Stage 1: Build
# ================================
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (for better Docker cache)
COPY package*.json ./

# Install all dependencies
RUN npm ci --only=production

# ================================
# Stage 2: Production
# ================================
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Add a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source code
COPY . .

# Remove .env if accidentally copied (we use environment variables in Docker)
RUN rm -f .env

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose backend port
EXPOSE 5000

# Health check - makes sure the server is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:5000/api/health || exit 1

# Start the server
CMD ["node", "server.js"]
