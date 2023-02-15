require 'json'
require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'example.Config' do
    repeated :rows, :message, 1, 'example.ConfigRow'
  end

  add_message 'example.ConfigRow' do
    repeated :values, :message, 1, 'example.Value'
  end

  add_message 'example.Value' do
    optional :string, :string, 1
  end
end

module Example
  Config = Google::Protobuf::DescriptorPool.generated_pool.lookup('example.Config').msgclass
  ConfigRow = Google::Protobuf::DescriptorPool.generated_pool.lookup('example.ConfigRow').msgclass
  Value = Google::Protobuf::DescriptorPool.generated_pool.lookup('example.Value').msgclass
end

content = { "rows": [{ "values": [{ "string": 'hello' }, { "string": 'world' }] },
                     { "values": [{ "string": 'thanks' },
                                  { "string": 'again' }] }] }.to_json

config = Example::Config.decode_json(content)

thread_count = 500
iterations_per_thread = 100_000

threads = []
(1..thread_count).each do |_i|
  threads << Thread.new do
    (1..iterations_per_thread).each do |_iter|
      config.rows.each do |row|
        row.values.each do |conditional_value|
          conditional_value
        end
      end
    end
  end
end

threads.map(&:join)

puts 'DONE!'
