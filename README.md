# Pact.js 101

## Usage

---
### Prerequisite

* `git clone https://github.com/skyrex-mark/Pact-Tutorial-for-Beginner.git`

---
### Step 1 - Install a pact broker on your local machine

* Install ruby 2.2.0 or later and bundler >= 1.12.0
  * Windows users: get a Rails/Ruby installer from [RailsInstaller](http://railsinstaller.org/) and run it
  * unix users `sudo apt install ruby-full`
* oepn a new terminal
* Run `git clone https://github.com/pact-foundation/pact_broker.git && cd pact_broker/example` or `cd pact_broker/example`
* Run `bundle install`
* Run `bundle exec rackup -p 8080` (this will use a Sqlite database. If you want to try it out with a Postgres database, see the [README](https://github.com/pact-foundation/pact_broker/tree/master/example) in the example directory.)
* Open [http://localhost:8080](http://localhost:8080) and you should see a list containing the pact between the Zoo App and the Animal Service
* Click the name of either a provider or consumer
* Click on the arrow to see the generated HTML documentation
* Click on either service to see an autogenerated network diagram
* Click on the HAL Browser link to have a poke around the API
* Click on the book icon under "docs" to view documentation related to a given relation

### Step 2 - Generate a pact file from the client side and publish back to the local pact broker

* open a new terminal
* `cd` to client directory
* run `npm install` or `yarn install`
* run `npm run test` or `yarn test`, if the test fails , try to run `mocha -t 50000 consumer.spec.js` instead
* a pact file will be genreated in the `pacts` folder
* run `npm run publish` or `yarn publish`, the pact file.will be published to the local pact broker

### Step 3- Verifiy the pact and publish the result to the local pact broker

* open a new terminal
* `cd api-service`
* run `npm install` or `yarn install`.
* run `npm start` or `yarn start` to spin up .a local api service
* open a new terminal
* `cd` to api-service directory
* run `npm run test` or `yarn test` to retrieve the pact from the local broker , verify the pact with local service and send the verification result back to the pact broker

---
### Alternative Hosting Solution

### Use Dockerized Pact Broker

* ##### If you want to use docker to host the pact broker instead of hosting it on your local machine, you can follow the steps below

* Install Docker from here https://www.docker.com/community-edition
* open a new terminal
* `git clone https://github.com/DiUS/pact_broker-docker.git`
* `cd pact_broker-docker`
* run `docker-compose up`
* Wait for the pact broker to go online

---
### Special Thanks

[@JiahuaZhang](https://github.com/JiahuaZhang) for helping  me to review this tutorial.