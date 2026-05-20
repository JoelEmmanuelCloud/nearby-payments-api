/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

const CACHE_PATH = /^\/cache\/(ac|cas)\/([a-f0-9]{64})$/;

function text(status: number, body: string): Response {
  return new Response(body, { status });
}

function authorized(request: Request, env: Env): boolean {
  const auth = request.headers.get("authorization");
  return auth === `Bearer ${env.BAZEL_CACHE_TOKEN}`;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (!authorized(request, env)) {
      return text(401, "Unauthorized");
    }

    const url = new URL(request.url);
    const match = url.pathname.match(CACHE_PATH);

    if (!match) {
      return text(404, "Not Found");
    }

    const key = `${match[1]}/${match[2]}`;

    switch (request.method) {
      case "PUT": {
        if (!request.body) {
          return text(400, "Missing request body");
        }

        await env.nearby_bazel_cache.put(key, request.body, {
          httpMetadata: {
            contentType: "application/octet-stream",
          },
        });

        return new Response(null, { status: 200 });
      }

      case "GET": {
        const object = await env.nearby_bazel_cache.get(key);

        if (!object) {
          return text(404, "Not Found");
        }

        return new Response(object.body, {
          status: 200,
          headers: {
            "content-type": "application/octet-stream",
            "content-length": object.size.toString(),
            etag: object.httpEtag,
            "cache-control": "private, max-age=31536000, immutable",
          },
        });
      }

      case "HEAD": {
        const object = await env.nearby_bazel_cache.head(key);

        if (!object) {
          return text(404, "Not Found");
        }

        return new Response(null, {
          status: 200,
          headers: {
            "content-length": object.size.toString(),
            etag: object.httpEtag,
          },
        });
      }

      default:
        return text(405, "Method Not Allowed");
    }
  },
} satisfies ExportedHandler<Env>;
