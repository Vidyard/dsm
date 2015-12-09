require 'spec_helper'

describe Time do
  it 'should calcualte duration and averages all the same after a single measurement' do
    time = ::Dsm::Time.new
    time.measure(1) do
      sleep(0.01)
    end

    expect(time.total_duration).to eq(time.recent_average)
    expect(time.total_duration).to eq(time.overall_average)
  end

  it 'should calcualte overall average as half the total duration on 2 iterations' do
    time = ::Dsm::Time.new
    for n in 1..2
      time.measure(n) do
        sleep(0.01)
      end
    end

    expect(time.overall_average).to eq(time.total_duration/2.0)
  end

  it 'should track recent average on only last 10 iterations' do
    time = ::Dsm::Time.new
    for n in 1..10
      time.measure(n) do
        sleep(0.01)
      end
    end
    for n in 11..20
      time.measure(n) do
        sleep(0.1)
      end
    end

    expect(time.overall_average).to be_within(0.002).of(0.055)
    expect(time.recent_average).to be_within(0.002).of(0.101)
  end

  it 'should track total duration over multiple iterations' do
    time = ::Dsm::Time.new
    for n in 1..10
      time.measure(n) do
        sleep(0.01)
      end
    end

    expect(time.total_duration).to be_within(0.002).of(0.110)
  end
end
