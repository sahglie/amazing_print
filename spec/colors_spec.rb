# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AmazingPrint' do
  def stub_tty!(output = true, stream = STDOUT)
    if output
      stream.instance_eval do
        def tty?
          true
        end
      end
    else
      stream.instance_eval do
        def tty?
          false
        end
      end
    end
  end

  describe 'colorization' do
    PLAIN = '[ 1, :two, "three", [ nil, [ true, false ] ] ]'
    COLORIZED = "[ \e[1;34m1\e[0m, \e[0;36m:two\e[0m, \e[0;33m\"three\"\e[0m, [ \e[1;31mnil\e[0m, [ \e[1;32mtrue\e[0m, \e[1;31mfalse\e[0m ] ] ]"

    before do
      ENV['TERM'] = 'xterm-colors'
      ENV.delete('ANSICON')
      @arr = [1, :two, 'three', [nil, [true, false]]]
    end

    describe 'default settings (no forced colors)' do
      before do
        AmazingPrint.force_colors! false
      end

      it 'colorizes tty processes by default' do
        stub_tty!
        expect(@arr.ai(multiline: false)).to eq(COLORIZED)
      end

      it "colorizes processes with ENV['ANSICON'] by default" do
        begin
          stub_tty!
          term = ENV['ANSICON']
          ENV['ANSICON'] = '1'
          expect(@arr.ai(multiline: false)).to eq(COLORIZED)
        ensure
          ENV['ANSICON'] = term
        end
      end

      it 'does not colorize tty processes running in dumb terminals by default' do
        begin
          stub_tty!
          term = ENV['TERM']
          ENV['TERM'] = 'dumb'
          expect(@arr.ai(multiline: false)).to eq(PLAIN)
        ensure
          ENV['TERM'] = term
        end
      end

      it 'does not colorize subprocesses by default' do
        begin
          stub_tty! false
          expect(@arr.ai(multiline: false)).to eq(PLAIN)
        ensure
          stub_tty!
        end
      end
    end

    describe 'forced colors override' do
      before do
        AmazingPrint.force_colors!
      end

      it 'still colorizes tty processes' do
        stub_tty!
        expect(@arr.ai(multiline: false)).to eq(COLORIZED)
      end

      it "colorizes processes with ENV['ANSICON'] set to 0" do
        begin
          stub_tty!
          term = ENV['ANSICON']
          ENV['ANSICON'] = '1'
          expect(@arr.ai(multiline: false)).to eq(COLORIZED)
        ensure
          ENV['ANSICON'] = term
        end
      end

      it 'colorizes dumb terminals' do
        begin
          stub_tty!
          term = ENV['TERM']
          ENV['TERM'] = 'dumb'
          expect(@arr.ai(multiline: false)).to eq(COLORIZED)
        ensure
          ENV['TERM'] = term
        end
      end

      it 'colorizes subprocess' do
        begin
          stub_tty! false
          expect(@arr.ai(multiline: false)).to eq(COLORIZED)
        ensure
          stub_tty!
        end
      end
    end

    describe 'uncolor' do
      it 'removes any ANSI color codes' do
        expect('red'.red + 'blue'.blue).to eq "\e[1;31mred\e[0m\e[1;34mblue\e[0m"
        expect(('red'.red + 'blue'.blue).uncolor).to eq 'redblue'
      end
    end
  end
end
