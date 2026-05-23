const http = require("node:http");

const port = 3000;
const appName = process.env.APP_NAME || "demo";

const server = http.createServer((req, res) => {
  const body = {
    app: appName,
    host: req.headers.host,
    url: req.url,
    message: "Hello from Docker behind Traefik",
    time: new Date().toISOString(),
  };

  res.writeHead(200, { "content-type": "application/json" });
  res.end(JSON.stringify(body, null, 2));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`${appName} listening on ${port}`);
});
