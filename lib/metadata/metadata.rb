module Scale
  module Types
    class Metadata
      include SingleValue
      def self.decode(scale_bytes)
        bytes = scale_bytes.get_next_bytes(4)
        if bytes.bytes_to_utf8 == 'meta'
          metadata_version = Scale::Types.type_of('Enum', [
                                      'MetadataV0',
                                      'MetadataV1',
                                      'MetadataV2',
                                      'MetadataV3',
                                      'MetadataV4',
                                      'MetadataV5',
                                      'MetadataV6',
                                      'MetadataV7',
                                      'MetadataV8',
                                      'MetadataV9',
                                      'MetadataV10'
                                    ]).decode(scale_bytes).value
          Metadata.new "Scale::Types::#{metadata_version}".constantize.decode(scale_bytes)
        end
      end
    end

    class MetadataModule
      include SingleValue
      def self.decode(scale_bytes)
        name = String.decode(scale_bytes).value
        prefix = String.decode(scale_bytes).value

        result = {
          name: name,
          prefix: prefix
        }

        has_storage = Bool.decode(scale_bytes).value
        if has_storage
          storages = Scale::Types.type_of('Vec<MetadataModuleStorage>').decode(scale_bytes).value
          result[:storage] = storages.map(&:value)
        end

        has_calls = Bool.decode(scale_bytes).value
        if has_calls
          calls = Scale::Types.type_of('Vec<MetadataModuleCall>').decode(scale_bytes).value
          result[:calls] = calls.map(&:value)
        end

        has_events = Bool.decode(scale_bytes).value
        if has_events
          events = Scale::Types.type_of('Vec<MetadataModuleEvent>').decode(scale_bytes).value
          result[:events] = events.map(&:value)
        end

        MetadataModule.new(result)
      end
    end

    class MetadataModuleStorage
      include SingleValue
      def self.decode(scale_bytes)
        result = {
          name: String.decode(scale_bytes).value,
          modifier: Scale::Types.type_of('Enum', %w[Optional Default]).decode(scale_bytes).value
        }

        is_key_value = Bool.decode(scale_bytes).value
        result[:type] = if is_key_value
                          {
                            Map: {
                              key: adjust(String.decode(scale_bytes).value),
                              value: adjust(String.decode(scale_bytes).value),
                              linked: Bool.decode(scale_bytes).value
                            }
                          }
                        else
                          {
                            Plain: adjust(String.decode(scale_bytes).value)
                          }
                        end

        result[:fallback] = Hex.decode(scale_bytes).value
        result[:documentation] = Scale::Types.type_of('Vec<String>').decode(scale_bytes).value.map(&:value)

        MetadataModuleStorage.new(result)
      end
    end

    class MetadataModuleCall
      include SingleValue
      def self.decode(scale_bytes)
        result = {}
        result[:name] = String.decode(scale_bytes).value
        result[:args] = Scale::Types.type_of('Vec<MetadataModuleCallArgument>').decode(scale_bytes).value.map(&:value)
        result[:documentation] = Scale::Types.type_of('Vec<String>').decode(scale_bytes).value.map(&:value)
        MetadataModuleCall.new(result)
      end
    end

    class MetadataModuleCallArgument
      include SingleValue
      def self.decode(scale_bytes)
        result = {}
        result[:name] = String.decode(scale_bytes).value
        result[:type] = adjust(String.decode(scale_bytes).value)

        MetadataModuleCallArgument.new(result)
      end
    end

    class MetadataModuleEvent
      include SingleValue
      def self.decode(scale_bytes)
        result = {}
        result[:name] = String.decode(scale_bytes).value
        result[:args] = Scale::Types.type_of('Vec<String>').decode(scale_bytes).value.map(&:value)
        result[:documentation] = Scale::Types.type_of('Vec<String>').decode(scale_bytes).value.map(&:value)

        MetadataModuleEvent.new(result)
      end
    end
  end
end
