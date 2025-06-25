import { Elysia } from "elysia";
import { spawnOllama } from "../utils/spawnOllama";
import { z } from "zod";

export const genRoute = new Elysia().get("/api/gen", ({ query, set }) => {
  const schema = z.object({
    model: z.string(),
    content: z.string(),
  });

  const result = schema.safeParse(query);
  if (!result.success) {
    set.status = 400;
    return "Missing model or content";
  }

  const { model, content } = result.data;

  const stream = spawnOllama(model, content);
  set.headers["Content-Type"] = "text/plain; charset=utf-8";
  set.headers["Transfer-Encoding"] = "chunked";

  return new Response(stream);
});
