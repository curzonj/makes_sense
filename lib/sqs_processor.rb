require 'loggable'

class SqsProcessor
  class << self
    attr_reader :queue_name
    def subscribes_to(*args)
      # TODO fix this
      @queue_name = args.first
    end

    def interval(time)
      @interval = time
    end

    def get_interval
      @interval || 20
    end
  end

  include Loggable

  def run
    while true do
      #logger.debug("Woke up for another loop on #{self}")
      while msg = queue.receive do
        logger.debug("Received message on #{self}: (#{msg.id}) #{msg}")

        begin
          output = parse_message(msg)

          unless output.nil?
            result = on_message(output)
            msg.delete unless result === false
          end
        rescue
          raise if debug_mode?
          logger.error("Failed to process #{self}/#{msg.id}: #{$!.message}")

          remove_failing(msg)
        end
      end

      #logger.debug("Sleeping for #{self}")
      sleep(self.class.get_interval)
    end
  end

  def debug=(v)
    @debug_mode = (v == true)

    logger.level = Logger::DEBUG if debug_mode?
  end

  def debug_mode?
    (@debug_mode == true)
  end

  def remove_failing(msg)
    return unless failed?(msg)

    logger.warn("Removing #{msg.id} from the queue because it keeps failing")
    msg.delete
  end

  def failed?(msg)
    @failing_messages ||= {}
    @failing_messages[msg.id] ||= 0
    @failing_messages[msg.id] += 1

    @failing_messages[msg.id] > 3
  end

  def to_s
    queue.name
  end

  def on_message(message)
    raise NotImplementedError
  end

  def parse_message(msg)
    JSON.parse(msg.to_s)
  end

  def queue
    @queue ||= AmazonHelper.queue(self.class.queue_name)
  end
end
