const path = require('path');
const request = require('superagent');
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const expect = chai.expect;
const { Pact } = require('@pact-foundation/pact');
const publisher = require('@pact-foundation/pact-node');
const MOCK_PORT = 3000;
const LOG_LEVEL = process.env.LOG_LEVEL || 'WARN';

chai.use(chaiAsPromised);

describe('Pact', () => {
  const provider = new Pact({
    consumer: 'receiver',
    provider: 'sender',
    port: MOCK_PORT,
    log: path.resolve(process.cwd(), 'logs', 'mockserver-integration.log'),
    dir: path.resolve(process.cwd(), 'pacts'),
    logLevel: LOG_LEVEL,
    spec: 2
  });

  const ExpectedBody = [
    {
      message: 'hello'
    }
  ];

  before(done => {
    provider
      .setup()
      .then(() => {
        return provider.addInteraction({
          given: 'the service api endpoint is available',
          uponReceiving: 'a request for greeting',
          withRequest: {
            method: 'GET',
            path: '/hello',
            headers: { Accept: 'application/json' }
          },
          willRespondWith: {
            status: 200,
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: ExpectedBody
          }
        });
      })
      .then(() => done());
  });

  it('should returns a greeting message', done => {
    request
      .get(`http://localhost:${MOCK_PORT}/hello`)
      .set({ Accept: 'application/json' })
      .then(response => {
        expect(response.body).to.eql(ExpectedBody);
      })
      .then(() => done());
  });

  afterEach(() => provider.verify());
  after(() => provider.finalize());
});
