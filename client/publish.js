const pact = require('@pact-foundation/pact-node');
const path = require('path');
const opts = {
  providerBaseUrl: 'http://localhost:3000',
  pactFilesOrDirs: [path.resolve(process.cwd(), 'pacts')],
  pactBroker: 'http://localhost:8080',
  tags: ['test', 'hello'],
  consumerVersion: '1.0.0'
};

pact
  .publishPacts(opts)
  .then(() => {
    console.log('Pact contract publishing complete!');
  })
  .catch(e => {
    console.log('Pact contract publishing failed: ', e);
  });
