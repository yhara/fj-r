module FjR
  module Props
    def props(*names)
      class_eval <<-EOD
        def initialize(#{names.join ', '})
          #{names.map{|x| "@#{x}"}.join ', '} = #{names.join ', '}
        end
        attr_reader #{names.map(&:inspect).join ', '}
      EOD
    end
  end
end
