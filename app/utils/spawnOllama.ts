export async function spawnOllama(
  model: string,
  content: string
): Promise<ReadableStream<Uint8Array>> {
  return new ReadableStream({
    async start(controller) {
      try {
        const proc = Bun.spawn(["ollama", "run", model], {
          stdin: "pipe",
          stdout: "pipe",
          stderr: "pipe",
        });

        // Log stderr output
        const stderrReader = proc.stderr.getReader();
        (async () => {
          while (true) {
            const { value, done } = await stderrReader.read();
            if (done) break;
            console.error("[ollama stderr]", new TextDecoder().decode(value));
          }
        })().catch((err) => console.error("[stderr read error]", err));

        // Write content to ollama stdin
        proc.stdin.write(content);
        proc.stdin.end();

        // Pipe stdout to HTTP stream
        const reader = proc.stdout.getReader();

        while (true) {
          const { value, done } = await reader.read();
          if (done) break;
          controller.enqueue(value);
        }

        controller.close();
      } catch (err) {
        console.error("[ollama spawn failure]", err);
        controller.error(err);
      }
    },
  });
}
