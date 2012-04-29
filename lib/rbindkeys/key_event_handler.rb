# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  # retrive key binds with key event
  class KeyEventHandler

    LOG = LogUtils.get_logger name

    # event device to read events
    attr_reader :device

    # virtual device to write events
    attr_reader :virtual

    # defaulut key bind set which retrive key binds with a key event
    attr_reader :default_bind_resolver

    # current key bind set which retrive key binds with a key event
    attr_reader :bind_resolver

    # code set of pressed key on the event device
    attr_reader :pressed_key_set

    # code set of pressed keys on the virtual device
    attr_reader :virtual_pressed_key_set

    # pressed key binds
    attr_reader :active_bind_set

    def initialize dev, virtual_dev
      @device = dev
      @virtual = virtual_dev
      @default_bind_resolver = BindResolver.new
      @bind_resolver = @default_bind_resolver
      @pressed_key_set = []
      @virtual_pressed_key_set = []
      @active_bind_set = []
    end

    def load_config file
      code = File.read file
      instance_eval code, file
    end

  end

end
