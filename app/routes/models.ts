import { Elysia } from "elysia";
import { z } from "zod";
import { models } from "../utils/models";

const ModelSchema = z.object({
  label: z.string(),
  value: z.string(),
});

const ModelsResponseSchema = z.array(ModelSchema);

export const modelsRoute = new Elysia().get("/api/models", () => models, {
  Response: ModelsResponseSchema,
});
