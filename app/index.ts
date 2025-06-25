import { Elysia } from "elysia";
import { corsPlugin } from "./plugins/cors";
import { genRoute } from "./routes/gen";
import { modelsRoute } from "./routes/models";

const app = new Elysia()
  .use(corsPlugin)
  .use(genRoute)
  .use(modelsRoute)

  .listen(Bun.env.PORT ?? 2000);

console.log(
  `🚀 M3Chat backend running at http://localhost:${app.server?.port}`
);
