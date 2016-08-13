module FjR
  module Props
    def props(*names)
      class_eval <<-EOD
        def initialize(#{names.join ', '})
          #{names.map{|x| "@#{x}"}.join ', '} = #{names.join ', '}
          init
        end
        attr_reader #{names.map(&:inspect).join ', '}

        private

        # Override this method instead of #initialize.
        def init
        end
      EOD
    end
  end
end
