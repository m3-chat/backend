FROM oven/bun:1.1.13

WORKDIR /app

COPY package.json bun.lock ./ 
RUN bun install --frozen-lockfile

COPY . .

ENV PORT=2000
EXPOSE 2000

CMD ["bun", "start"]
