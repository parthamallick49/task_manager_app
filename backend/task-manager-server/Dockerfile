# ---------- Stage 1: Build & install dependencies ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Copy only package files first (to leverage Docker cache)
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy the rest of the application
COPY . .

# ---------- Stage 2: Production Image ----------
FROM node:18-alpine AS production

WORKDIR /app

# Copy only the installed node_modules & app files from builder
COPY --from=builder /app /app

# Set environment variables
ENV NODE_ENV=production

# Expose port 5000
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
