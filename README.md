     ____                              ____       _     _
    | __ ) _   _ _ __ ___  _ __  _   _| __ ) _ __(_) __| | __ _  ___
    |  _ \| | | | '_ ` _ \| '_ \| | | |  _ \| '__| |/ _` |/ _` |/ _ \
    | |_) | |_| | | | | | | |_) | |_| | |_) | |  | | (_| | (_| |  __/
    |____/ \__,_|_| |_| |_| .__/ \__, |____/|_|  |_|\__,_|\__, |\___|
                          |_|    |___/                    |___/
# Welcome to BumpyBridge

Bridging RabbitMQ & Faye.

## Installation

Add this line to your application's Gemfile:

    gem 'bumpy_bridge'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bumpy_bridge

## Usage

Example `bumpy_bridge.yml`

    faye:
      server: http://localhost:9292/faye
      secret_token: supersecrettoken
    mappings:
      - source: faye:///stat
        target: rabbitmq://stat
      - source: faye:///register/listener
        target: rabbitmq://register.listener
      - source: rabbitmq://asd.f
        target: faye:///asd/f

Then run in the directory of the config file

    bumpy_bridge run

Run with `DEBUG=1` for more output.

    DEBUG=1 bumpy_bridge run

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
