module Callbacks
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  def run_callbacks(name)
    send("_#{name}_callbacks")
  end
  
  module ClassMethods
    def callback_uuid
      @@callback_uuid ||= 0
      @@callback_uuid += 1
      "_callback_#{@@callback_uuid}"
    end
    
    def compile_callbacks(name, callbacks)
      meth_string = ""
      callbacks.each do |callback|
        callback_name = compile_callback(callback)
        meth_string << "#{callback_name}\n"
      end
      class_eval <<-RUBY_EVAL
        def _#{name}_callbacks
          #{meth_string}
        end
      RUBY_EVAL
    end
    
    def compile_callback(callback)
      case callback
      when Symbol
        callback
      when Proc
        name = callback_uuid
        define_method(name, &callback)
        "#{name}(self)"
      end
    end
    
    def define_callback(name)
      class_eval <<-RUBY_EVAL
        def self._#{name}_callbacks
          @_#{name}_callbacks
        end

        def self.#{name}_callback(obj = nil, &blk)
          obj ||= blk
          @_#{name}_callbacks ||= []
          @_#{name}_callbacks << obj
          compile_callbacks(:#{name}, @_#{name}_callbacks)
        end
      RUBY_EVAL
    end
  end
end