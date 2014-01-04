unless Array.instance_methods.include?(:to_h)
  class Array
    def to_h
      Hash[*flatten(1)]
    end
  end
end
