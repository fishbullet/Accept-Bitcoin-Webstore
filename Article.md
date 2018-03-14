# Accept bitcoin in website

**Bitcoin** is a decentralised digital currency which has been growing rapidly in popularity and use.
You can send **bitcoins** to people and businesses around the world quickly, easily, and
with much less fees than international wire transfers, PayPal, or Visa, e.t.c. 

This is a step-by-step guide, how to accept **bitcoin** in your website
without using the full node or third-party service like [blockchain.info](https://blockchain.info/) or [blocktrail.com](https://www.blocktrail.com/)
or any other bitcoin-wallet site. 

Nowadays the full **bitcoin** node is too huge to storage on the low-cost VPS,
for example current full node occupies *186G* (13 March 2018).

We are going to create a _simple store website_ with the users and they accounts,
every account will have an address to receive payments in *bitcoin* in order to deposit balance.

We'll use the [electrum wallet](http://docs.electrum.org/en/latest/faq.html#) is a S.P.V client.

> S.P.V. or Simplified Payment Verification - A method for verifying if particular transactions are included
> in a block without downloading the entire block.

## Requirements

I'm going to use linux OS with `Docker` and `Postgresql` database.

<sub>You may work without `Docker`, just run all commands from the `launch_electrum` script.</sub>

I assume you're able to use linux command line and you have some knowledge about `Docker`, `Ruby on Rails` and shell scripting.

I have created the Rails application and setup it, you can clone it from [here](#LINK_HERE).
That's a simple Rails application. The Robot Store.

---

## Checklist

### Wallet steps:

- [x] [Prepare and build wallet image](#prepare-and-build-wallet-image)
- [x] [Setup electrum wallet](#setup-electrum-wallet)
- [x] [Test RPC server](#test-rpc-server)

### Web application:

- [x] [Database and application design](#database-and-application-desing)
- [x] [RPC provider](#rpc-provider)

### Use cases:

- [x] [Reg user and request address](#)
- [x] [Payment processing](#)

---

## Prepare and build wallet image

I'll use the `Docker` image with Ubuntu OS, here is `Dockerfile`:

```Dockerfile
FROM ubuntu:16.04
LABEL version="1.0"
LABEL maintainer="shindu666@gmail.com"

# Set electrum wallet version here
ENV ELECTRUM_VERSION 3.1.1
# RPC settings passed by env variables
ENV RPCPORT 8443
ENV RPCHOST 0.0.0.0
ENV RPCUSER admin1
ENV RPCPASSWORD admin1

ENV DEBIAN_FRONTEND=noninteractive

# Install electrum depends.
RUN apt-get update && \
 apt-get install --yes wget software-properties-common python-qt4 python3-setuptools python3-pyqt5 python3-pip

# Copy setup file
COPY launch_electrum .

ENTRYPOINT bash
```

From the folder with `Dockerfile` build image: 

```bash
sudo docker build -t electrum .
Sending build context to Docker daemon  81.46MB
Step 1/12 : FROM ubuntu:16.04
 ---> 2a4cca5ac898
Step 2/12 : ENV ELECTRUM_VERSION 3.1.1
 ---> Using cache
 ---> ed7976d13167
Step 3/12 : ENV RPCPORT 8443
 ---> Using cache
 ---> 645799a9869a
Step 4/12 : ENV RPCHOST 0.0.0.0
 ---> Using cache
 ---> 79287a26b3d6
Step 5/12 : ENV RPCUSER admin1
 ---> Using cache
 ---> b2aa80fae400
Step 6/12 : ENV RPCPASSWORD admin1
 ---> Using cache
 ---> bd55826fd89b
Step 7/12 : LABEL version="1.0"
 ---> Using cache
... output omited ...
```

## Setup electrum wallet

Run image, you must see shell prompt, run `launch_electrum` to setup wallet(**you must enter wallet password and save the seed phrase!**):

```bash
sudo docker run -it --rm -p 8443:8443 electrum
root@2862317a0ff2:/# ./launch_electrum 
Download electrum-3.1.1 ...
Setup configuration ...
Setup RPC PORT => 8443 ...
true
Setup RPC HOST => 0.0.0.0 ...
true
Setup RPC USER => admin1 ...
true
Setup RPC PASSWORD => admin1 ...
true
Setup wallet password >>>
Password (hit return if you do not wish to encrypt your wallet):
Your wallet generation seed is:
"beach elegant half scheme inject such diet profit boost silly bike bicycle"
Please keep it in a safe place; if you lose it, you will not be able to restore your wallet.
Wallet saved in '/root/.electrum/testnet/wallets/default_wallet'
Load wallet >>>
starting daemon (PID 49)
true
Start daemon >>>
Press Ctrl+C to stop >>>
```

If you dont use `Docker` 
you can run this script step by step.
Read the comments carefully in order to
understand the purpose of the script commands.

## Test RPC server

At this point we have setup and run `electrum` wallet in the daemon mode, in order to check
if RPC server running successfully, ping it with the next `curl` command:

```bash
 curl --data-binary '{"id":"curltext","method":"getbalance","params":[]}' http://admin1:admin1@127.0.0.1:8443
```
Here’s what you should be seeing after running `curl` command:
```json
{
  "result": {
    "confirmed": "0"
  },
  "id": "curltext",
  "error": null
}
```
If the output other, you're doing something wrong, rollback and check all steps again.

## Database and application desing

Database tables:

1. Payments - is a bitcoin transaction with included block and value in satoshi.
2. Purshase - is a join table between users and robot items.
3. Robot - purchase item.

<p align="center"><img src="assets/webstore_database_1.png" width="560"></p>

There is a three abstraction which represent user balance:

1. Confirmed - is a sum of all **confirmed** incoming transactions(payment) minus sum of all purchases. 
2. Unconfirmed - is a sum of all **unconfirmed** transactions(payment)
3. Payments - sum of all purchases

The user balance calculated in this way:

```ruby
# user.rb
has_many :payments

def balance
  # / 100_000_000.0 - because values in the satoshi 0.00000001 BTC is 1 satoshi
  # but we store coins as integer not as decimal
  (confirmed - purchases.sum(:value)) / 100_000_000.0
end

def confirmed
  payments.where('included_in_block > 0').sum(:value)
end
```


## RPC provider

In order to communicate with wallet there is a module `PaymentProcessor` it is a simple http service
which talk with electrum RPC server.

```ruby
require 'httparty'

class PaymentProcessor
  include HTTParty
  base_uri "http://#{RobotStore::Application.secrets.btc_host}:#{RobotStore::Application.secrets.btc_port}"

  def initialize
    @request_id = 0
    @options = {
      headers: { "Content-Type" => "application/json" },
      basic_auth: {
        username: RobotStore::Application.secrets.btc_user,
        password: RobotStore::Application.secrets.btc_password
      }
    }
  end

  def get_new_address
    request do
      build_params("createnewaddress")
    end
  end

  def get_address_unspent(address)
    request do
      build_params("getaddressunspent", address)
    end
  end

  def body
    @body["result"]
  end

  def success?
    @success
  end

  private

  def request
    @request_id = @request_id.next
    response = self.class.post(
      "/", 
      @options.merge!(body: yield.to_json)
    )
    @body, @success = response.parsed_response, response.success?
  end
  

  def build_params(method, params = nil)
    {
      id: @request_id,
      method: method,
      params: [params].compact 
    }
  end
end
```

Here is a diagram:

<p align="center"><img src="assets/store.png" width="560"></p>

## Reg a user and request address

At this step we have:

* RPC wallet runned in daemon mode.
* Rails application with RPC module.
* Users, Purchase, Robot, Payment model.

Let's buy some robot now! 

Setup and run Rails application. Here are steps.

<sub> You can clone an example [here]() </sub>

0. `cd robot_store` 
1. `bundle install` - install Rails depends.
2. `bundle exec rake db:create` - create database.
3. `bundle exec rake db:migrate` - run database migrations.
4. `bundle exec rake db:seed` - seed database with some robots.
5. `bundle exec rails server` - run rails server.

Open the [robot store](http://localhost:3000/) and reg a user.

<p align="center"><img src="assets/webstore_step_1.png" width="560"></p>

Here’s what you should be seeing after success registration:

<p align="center"><img src="assets/webstore_step_2.png" width="560"></p>

At this point we cant buy any robots, need to deposit some coins.
After successfull address request you'll see:

<p align="center"><img src="assets/webstore_step_3.png" width="560"></p>

Now we have an address and we can deposit some coins.
I'll use a [facuet](https://testnet.manu.backend.hamburg/faucet).
Copy address and reqeust some coins.
Now we should wait at least one confirmation.
In order to update our payments we'll run rake task `bundle exec rake pull_payments`.
Here is what you'll see if you have any transaction on this address.

<p align="center"><img src="assets/webstore_step_4.png" width="560"></p>

There is unconfirmed balance `B1.30000000`. That's good, now wait confirmations and run `bundle exec rake pull_payments` periodically.

After sometime your balance must change from unconfirmed to confirmed and you'll able to buy some robots.

<p align="center"><img src="assets/webstore_step_5.png" width="560"></p>

## Closing

We have create step by step a Rails webstore application with robot merchants and payments in bitcoins.
In this guide we have used bitcoin `testnet` but you can try to use it with `mainnet`.

## Donation

Buy me a beer:

* 19SYMA2hqRZHRSL4di35Uf7jV87KBKc9bf
* 0xD7cc10f0d70Fd8f9fB83D4eF9250Fc9201981e3a

Happy hacking!

