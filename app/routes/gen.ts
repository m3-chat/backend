import { Elysia } from "elysia";
import { z } from "zod";
import { spawnOllama } from "../utils/spawnOllama";

const querySchema = z.object({
  model: z.string().min(1, "Model name is required"),
  content: z.string().min(1, "Content to send to the model is required"),
});

export const genRoute = new Elysia().get("/api/gen", async ({ query, set }) => {
  const parse = querySchema.safeParse(query);

  if (!parse.success) {
    const errorMessages = parse.error.issues.map(
      (issue) => `${issue.path.join(".")}: ${issue.message}`
    );
    set.status = 400;
    return {
      error: "Invalid query parameters",
      details: errorMessages,
    };
  }

  const { model, content } = parse.data;

  try {
    const stream = await spawnOllama(model, content);
    set.headers["Content-Type"] = "text/plain; charset=utf-8";
    set.headers["Transfer-Encoding"] = "chunked";
    return new Response(stream);
  } catch (err: any) {
    console.error("[spawnOllama error]", err);
    set.status = 500;
    return {
      error: "Failed to stream response from ollama",
      details: err?.message ?? "Unknown error",
    };
  }
});
