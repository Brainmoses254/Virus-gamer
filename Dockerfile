# Multi-stage Dockerfile for a Node.js app (works for server apps or apps that build assets)
# Adjust NODE_VERSION, ports, and build/start scripts as needed.

# Stage 1 — install production deps separately (cache-friendly)
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Stage 2 — install dev deps and build the app (if you have a build step)
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
# If you have a build step, ensure dev deps are available
RUN npm ci
# Replace with your build script (e.g. react/svelte/vue/build or ts compile)
RUN --mount=type=cache,target=/root/.npm npm run build

# Stage 3 — final smaller runtime image
FROM node:20-alpine AS release
WORKDIR /app
ENV NODE_ENV=production
# Copy production node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules
# Copy built app from builder (or entire source if no build output)
COPY --from=builder /app ./

# Expose the port your app listens on
EXPOSE 3000

# Default command — adjust if your app uses a different start script or entrypoint
CMD ["npm", "start"]
