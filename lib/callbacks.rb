module Callbacks
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  def run_callbacks(name)
    callbacks = self.class.send(
      "_#{name}_callbacks")
    callbacks.each do |callback|
      case callback
      when Symbol
        send(callback)
      when Proc
        callback.call(self)
      end
    end
  end
  
  module ClassMethods
    def define_callback(name)
      class_eval <<-RUBY_EVAL
        def self._#{name}_callbacks
          @_#{name}_callbacks
        end

        def self.#{name}_callback(obj = nil, &blk)
          obj ||= blk
          @_#{name}_callbacks ||= []
          @_#{name}_callbacks << obj
        end
      RUBY_EVAL
    end
  end
end