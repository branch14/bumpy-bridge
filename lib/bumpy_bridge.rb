$:.unshift File.dirname(__FILE__)

require 'bumpy_bridge/version'

require 'json'

require 'faye'
require 'faye/authentication'
require 'bunny'
require 'daemons'
require 'trickery'

DEBUG = ENV['DEBUG']

class BumpyBridge

  include Trickery::Config

  attr_accessor :config, :faye, :bunny, :bunny_channel

  def initialize(file)
    self.config = read_config(file)
  end

  def run
    # setup rabbitmq
    self.bunny = Bunny.new read_timeout: 10, heartbeat: 10
    bunny.start
    self.bunny_channel = bunny.create_channel

    # setup faye
    EM.run {
      self.faye = Faye::Client.new(config.faye.server)
      auth_ext = Faye::Authentication::ClientExtension.new(config.faye.secret_token)
      faye.add_extension(auth_ext)

      # establish callbacks
      config.mappings.each do |mapping|
        sprot, schan = mapping.source.split('://')
        tprot, tchan = mapping.target.split('://')
        case [sprot, tprot] * ' -> '
        when 'faye -> rabbitmq' then faye2bunny(schan, tchan, mapping)
        when 'rabbitmq -> faye' then bunny2faye(schan, tchan, mapping)
        else warn "Unknown mapping: #{sprot} -> #{tprot}"
        end
      end
    }
  rescue => e
    puts "FATAL: #{e}"
  end

  private

  def faye2bunny(source, target, mapping)
    puts "faye2rabbitmq [#{source} -> #{target}]" if DEBUG
    type, name = target.split('/')

    options = {}
    exchange = nil

    case type
    when 'exchange'
      exchange = bunny_channel.fanout(name)
    when 'queue'
      queue = bunny_channel.queue(name)
      exchange = bunny_channel.default_exchange
      options[:routing_key] = queue.name
    else raise "Unkown target type: #{type}"
    end

    faye.subscribe(source) do |data|
      puts "[#{source} -> #{target}] #{data.inspect}" if DEBUG
      exchange.publish(JSON.unparse(data), options)
    end
  end

  def bunny2faye(source, target, mapping)
    puts "rabbitmq2faye [#{source} -> #{target}]" if DEBUG
    mapping.options ||= {}
    type, name = source.split('/')
    queue = nil

    case type
    when 'exchange'
      # create an own queue and bind it to the given exchange
      exchange = bunny_channel.fanout(name)
      queue = bunny_channel.queue('', exclusive: true)
      queue.bind exchange
    when 'queue'
      # pull events directly from the given queue
      queue = bunny_channel.queue(name)
    else raise "Unknown source type: #{type}"
    end

    queue.subscribe(mapping.options) do |info, prop, body|
      data = JSON.parse(body)
      puts "[#{source} -> #{target}] #{data.inspect}" if DEBUG
      faye.publish(target, data)
    end
  end

end
