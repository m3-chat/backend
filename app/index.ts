import { Elysia } from "elysia";
import { cors } from "./plugins/cors";
import { compression } from "./plugins/compression";
import { genRoute } from "./routes/gen";
import { statusRoute } from "./routes/status";

const app = new Elysia()
  .use(cors())
  .use(compression())
  .use(genRoute)
  .use(statusRoute)
  .listen(Bun.env.PORT ?? 2000);

console.log(
  `🚀 M3Chat backend running at http://localhost:${app.server?.port}`
);
