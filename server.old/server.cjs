import jsonServer from 'json-server';
const server = jsonServer.create();

// Add the /api prefix rewrite rule
server.use(jsonServer.rewriter({ '/api/*': '/$1' }));

server.use(jsonServer.defaults());
server.use(jsonServer.router('db.json'));

server.listen(4000, () => {
  console.log('JSON Server is running with /api prefix on port 4000');
});