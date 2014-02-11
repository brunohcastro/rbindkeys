# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe CLI do
  describe '#.main' do
    context ', when ARGV is empty,' do
      before do
        @args = []
      end
      it 'shoud exit with code 1' do
        expect { CLI::main @args }.to raise_error do |e|
          e.should be_a SystemExit
          e.status.should == 1
        end
      end
    end
    context ', when ARGV have an argument,' do
      before do
        @args = ['foo']
        @observer = double Observer
        Observer.should_receive(:new){@observer}
        @observer.should_receive(:start){nil}
      end
      it 'should call Observer#new#start' do
        config = CLI::config
        CLI::main @args
        CLI::config.should == config
      end
    end
    context ', when ARGV have an invalid option (--config),' do
      before do
        @args = ['--config']
      end
      it 'should exit with code 1' do
        expect { CLI::main @args }.to raise_error do |e|
          e.should be_a SystemExit
          e.status.should == 1
        end
      end
    end
    context ', when ARGV have an option (--config) and an event device,' do
      before do
        @config = 'a_config_file'
        @args = ['--config', @config,'foodev']
        @observer = double Observer
        Observer.should_receive(:new){@observer}
        @observer.should_receive(:start){nil}
      end
      it 'should call Observer#new#start ' do
        CLI::main @args
        CLI::config.should == @config
      end
    end
    context ', when ARGV have an option (--evdev-list),' do
      before do
        @args = ['--evdev-list']
        @evdev = double Revdev::EventDevice
        @id = double Object
        @evdev.stub(:device_name){"foo"}
        @evdev.stub(:device_id){@id}
        @id.stub(:hr_bustype){'bar'}
        Revdev::EventDevice.stub(:new){@evdev}
        Dir.should_receive(:glob).with(CLI::EVDEVS).
          and_return(['/dev/input/event4','/dev/input/event2',
                      '/dev/input/event13'])
      end
      it 'should pring device info' do
        CLI::main @args
      end
    end
  end
end
