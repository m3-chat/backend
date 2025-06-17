using System.Diagnostics;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors();
builder.Services.AddResponseCompression();

var app = builder.Build();

app.UseCors(policy => policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
app.UseResponseCompression();

app.MapGet("/api/gen", async (HttpContext context) =>
{
    var model = context.Request.Query["model"].ToString();
    var content = context.Request.Query["content"].ToString();

    if (string.IsNullOrWhiteSpace(model) || string.IsNullOrWhiteSpace(content))
    {
        context.Response.StatusCode = 400;
        await context.Response.WriteAsync("Missing model or content");
        return;
    }

    context.Response.ContentType = "text/plain; charset=utf-8";

    var psi = new ProcessStartInfo
    {
        FileName = "ollama",
        Arguments = $"run {model}",
        RedirectStandardInput = true,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false
    };

    var process = new Process { StartInfo = psi, EnableRaisingEvents = true };

    process.OutputDataReceived += async (_, e) =>
    {
        if (e.Data != null)
        {
            await context.Response.WriteAsync(e.Data + "\n");
            await context.Response.Body.FlushAsync();
        }
    };

    process.ErrorDataReceived += (_, e) =>
    {
        if (!string.IsNullOrEmpty(e.Data))
            Console.Error.WriteLine(e.Data);
    };

    process.Start();
    process.BeginOutputReadLine();
    process.BeginErrorReadLine();

    await process.StandardInput.WriteAsync(content);
    process.StandardInput.Close();

    await process.WaitForExitAsync();
});

app.Run("http://localhost:2000");
