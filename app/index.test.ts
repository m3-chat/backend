import { Elysia } from "elysia";

new Elysia().get("/", () => "Hello").listen(3000);
