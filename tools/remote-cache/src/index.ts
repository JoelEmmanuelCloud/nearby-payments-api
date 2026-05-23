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
const MAVEN_PATH = /^\/maven\/(.+)$/;

function text(status: number, body: string): Response {
  return new Response(body, { status });
}

function cacheObjectHeaders(object: R2Object): Headers {
  return new Headers({
    "content-type": "application/octet-stream",
    "content-length": object.size.toString(),
    etag: object.httpEtag,
    "cache-control": "private, max-age=31536000, immutable",
  });
}

function mavenObjectHeaders(object: R2Object): Headers {
  const headers = new Headers();

  object.writeHttpMetadata(headers);
  headers.set("content-length", object.size.toString());
  headers.set("etag", object.httpEtag);
  headers.set("cache-control", "public, max-age=300");

  if (!headers.get("content-type")) {
    headers.set("content-type", "text/plain");
  }

  return headers;
}

function authorized(request: Request, env: Env): boolean {
  const auth = request.headers.get("authorization");
  return auth === `Bearer ${env.BAZEL_CACHE_TOKEN}`;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const mavenMatch = url.pathname.match(MAVEN_PATH);

    if (mavenMatch) {
      return handleMavenRepository(request, env, mavenMatch[1]);
    }

    if (!authorized(request, env)) {
      return text(401, "Unauthorized");
    }

    const cacheMatch = url.pathname.match(CACHE_PATH);

    if (cacheMatch) {
      return handleBazelCache(request, env, cacheMatch);
    }

    return text(404, "Not Found");
  },
} satisfies ExportedHandler<Env>;

async function handleBazelCache(
  request: Request,
  env: Env,
  match: RegExpMatchArray,
): Promise<Response> {
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
        headers: cacheObjectHeaders(object),
      });
    }

    case "HEAD": {
      const object = await env.nearby_bazel_cache.head(key);

      if (!object) {
        return text(404, "Not Found");
      }

      return new Response(null, {
        status: 200,
        headers: cacheObjectHeaders(object),
      });
    }

    default:
      return text(405, "Method Not Allowed");
  }
}

async function handleMavenRepository(
  request: Request,
  env: Env,
  relativePath: string,
): Promise<Response> {
  if (request.method !== "GET" && request.method !== "HEAD") {
    return text(405, "Method Not Allowed");
  }

  if (relativePath.includes("..")) {
    return text(400, "Invalid Maven path");
  }

  const key = `maven/${relativePath}`;

  if (request.method === "HEAD") {
    const object = await env.nearby_bazel_cache.head(key);

    if (!object) {
      return text(404, "Not Found");
    }

    return new Response(null, {
      status: 200,
      headers: mavenObjectHeaders(object),
    });
  }

  const object = await env.nearby_bazel_cache.get(key);

  if (!object) {
    return text(404, "Not Found");
  }

  return new Response(object.body, {
    status: 200,
    headers: mavenObjectHeaders(object),
  });
}
