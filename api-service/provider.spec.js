const { Verifier } = require('@pact-foundation/pact');
const opts = {
  provider: 'sender',
  providerBaseUrl: 'http://localhost:3000',
  pactUrls: [
    'http://localhost:8080/pacts/provider/sender/consumer/receiver/latest'
  ],
  publishVerificationResult: true,
  providerVersion: '1.0.0'
};

new Verifier()
  .verifyProvider(opts)
  .then(() => {
    console.log('Success!');
  })
  .catch(err => {
    console.log(err);
  });
