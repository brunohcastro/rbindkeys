# -*- coding:utf-8; mode:ruby; -*-


module Rbindkeys

  # main event loop class
  class Observer
    attr_reader :device, :config, :pressed_keys, :key_binds, :verbose

    def initialize config_name, device_location
      @device = Device.new device_location
      @virtual = VirtualDevice.new
      @config_file = config_name
      @pressed_keys = {}
      @key_binds = {}
      @verbose = true
    end

    # main loop
    def start
      @device.grab
      @virtual.create

      begin
        trap :INT, method(:destroy)
        trap :TERM, method(:destroy)
        @device.listen do |event|
          if event.type != EV_KEY
            @virtual.write_input_event event
          else
            puts "read #{event.hr_code}:#{event.value==1?'pressed':'released'}" if @verbose
            if resolve(event) == true
              @virtual.write_input_event event
            end
          end
        end
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t#{s.to_s}\n"}
        destroy
      end
    end

    def destroy
      begin
        @device.ungrab
        puts "success device.ungrab" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      begin
        @virtual.destroy
        puts "success virtural.destroy" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      exit true
    end

    def resolve event
      r = @key_binds[event.code]
      if not r.nil?
        r.call event, self
      else
        true
      end
    end

    def bind_key input, output = nil
      if block_given?
        if not output.nil?
          raise ArgumentError, "expect either output(2nd arg) or block"
        end
        # TODO regist to @key_binds
      elsif output.kind_of? Fixnum
        if input.kind_of? Fixnum
        else
          raise ArgumentError, "unexpected class (1st arg: #{input.class})"
        end
      else
        raise ArgumentError, "unexpected class (2nd arg: #{output.class})"
      end
    end

  end

end
