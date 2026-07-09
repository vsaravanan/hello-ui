# Dockerfile for hello-ui (Next.js frontend)
# Built on k8master using: buildah bud -t hello-ui:latest -f deploy/Dockerfile .
#
# pnpm install and pnpm run build already happened externally by
# k8master-build-ui.sh before this runs, so this is a single stage -
# no separate builder/runner containers, just package and run.

FROM node:20-alpine
WORKDIR /app
COPY . .

ENV NODE_ENV=production

EXPOSE 3000
CMD ["pnpm", "start"]
