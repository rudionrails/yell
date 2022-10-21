# frozen_string_literal: true

require 'spec_helper'

class DSLAdapter < Yell::Adapters::Base
  setup do |_options|
    @test_setup = true
  end

  write do |_event|
    @test_write = true
  end

  close do
    @test_close = true
  end

  def test_setup?
    @test_setup
  end

  def test_write?
    @test_write
  end

  def test_close?
    @test_close
  end
end

describe 'Yell Adapter DSL spec' do
  let(:event) { Yell::Event.new(Yell::Logger.new, 1, 'Hello World!') }

  it 'performs #setup' do
    adapter = DSLAdapter.new
    expect(adapter).to be_test_setup
  end

  it 'performs #write' do
    adapter = DSLAdapter.new
    expect(adapter).not_to be_test_write

    adapter.write(event)
    expect(adapter).to be_test_write
  end

  it 'performs #close' do
    adapter = DSLAdapter.new
    expect(adapter).not_to be_test_close

    adapter.close
    expect(adapter).to be_test_close
  end
end
