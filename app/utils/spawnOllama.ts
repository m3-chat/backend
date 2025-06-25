import { spawn } from "bun";
import { z } from "zod";

const spawnOllamaArgsSchema = z.object({
  model: z.string().min(1, "Model name must be a non-empty string"),
  content: z.string().min(1, "Content must be a non-empty string"),
});

export function spawnOllama(model: string, content: string) {
  // Validate arguments
  const parseResult = spawnOllamaArgsSchema.safeParse({ model, content });
  if (!parseResult.success) {
    throw new Error(
      "Invalid arguments to spawnOllama: " +
        parseResult.error.errors.map((e) => e.message).join("; ")
    );
  }

  return new ReadableStream({
    start(controller) {
      let proc;
      try {
        proc = spawn(["ollama", "run", model], {
          stdin: "pipe",
          stdout: "pipe",
          stderr: "pipe",
        });
      } catch (err) {
        controller.error(
          new Error("Failed to spawn ollama process: " + (err as Error).message)
        );
        return;
      }

      (async () => {
        const reader = proc.stdout.getReader();
        try {
          while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            if (value) controller.enqueue(value);
          }
        } catch (err) {
          controller.error(
            new Error(
              "Error reading from ollama stdout: " + (err as Error).message
            )
          );
        } finally {
          reader.releaseLock();
          controller.close();
        }
      })();

      (async () => {
        const reader = proc.stderr.getReader();
        try {
          while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            if (value) {
              const msg = new TextDecoder().decode(value);
              console.error("[ollama stderr]", msg);
            }
          }
        } catch (err) {
          console.error("Error reading from ollama stderr:", err);
        } finally {
          reader.releaseLock();
        }
      })();

      try {
        proc.stdin.write(content);
        proc.stdin.end();
      } catch (err) {
        controller.error(
          new Error(
            "Failed to write to ollama stdin: " + (err as Error).message
          )
        );
      }
    },
  });
}
