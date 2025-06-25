import { Elysia } from "elysia";
import { corsPlugin } from "./plugins/cors";
import { genRoute } from "./routes/gen";

const app = new Elysia()
  .use(corsPlugin)
  .use(genRoute)

  .listen(Bun.env.PORT ?? 2000);

console.log(
  `🚀 M3Chat backend running at http://localhost:${app.server?.port}`
);
