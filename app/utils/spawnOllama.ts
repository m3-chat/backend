import { spawn } from "bun";

export function spawnOllama(model: string, content: string) {
  return new ReadableStream({
    start(controller) {
      const proc = spawn(["ollama", "run", model], {
        stdin: "pipe",
        stdout: "pipe",
        stderr: "pipe",
      });

      (async () => {
        const reader = proc.stdout.getReader();
        try {
          while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            controller.enqueue(value);
          }
        } finally {
          reader.releaseLock();
        }
        controller.close();
      })();

      (async () => {
        const reader = proc.stderr.getReader();
        try {
          while (true) {
            const { value, done } = await reader.read();
            if (done) break;
            console.error(new TextDecoder().decode(value));
          }
        } finally {
          reader.releaseLock();
        }
      })();

      proc.stdin.write(content);
      proc.stdin.end();
    },
  });
}
