require 'spec_helper'

describe Mongo::Monitoring do

  describe '#publish' do

    context 'a sample listener to a query series of events' do

      # This is a simple example of a subscriber to events that simply logs them.
      class LogSubscriber

        # The notify method is the only method that needs to be implemented.
        def notify(event)
          logger = Logger.new($stdout)
          logger.info("MONGODB.#{event.topic} | #{event.payload} | (#{event.duration}s)")
        end
      end

      let(:subscriber) do
        LogSubscriber.new
      end

      before do
        Mongo::Monitoring.subscribe(Mongo::Monitoring::QUERY, subscriber)
        Mongo::Monitoring.subscribe(Mongo::Monitoring::GET_MORE, subscriber)
        Mongo::Monitoring.subscribe(Mongo::Monitoring::KILL_CURSORS, subscriber)

        102.times do |n|
          authorized_collection.insert_one({ name: "test_#{n}" })
        end
      end

      after do
        Mongo::Monitoring.send(:subscribers).clear

        authorized_collection.find.delete_many
      end

      it 'logs the events in the series' do
        authorized_collection.find.to_a
      end
    end
  end
end
