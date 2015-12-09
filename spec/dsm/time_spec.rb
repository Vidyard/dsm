require 'spec_helper'

describe Time do
  it 'should calcualte duration and averages all the same after a single measurement' do
    time = ::Dsm::Time.new
    time.measure(1, 1) do
      sleep(0.01)
    end

    expect(time.total_duration).to eq(time.recent_average)
    expect(time.total_duration).to eq(time.overall_average)
  end

  it 'should calcualte overall average as half the total duration on 2 iterations' do
    time = ::Dsm::Time.new
    for n in 1..2
      time.measure(n, 2) do
        sleep(0.01)
      end
    end

    expect(time.overall_average).to eq(time.total_duration/2.0)
  end

  it 'should track recent average on only last 10 iterations' do
    time = ::Dsm::Time.new
    for n in 1..10
      time.measure(n, 1) do
        sleep(0.01)
      end
    end
    for n in 11..20
      time.measure(n, 1) do
        sleep(0.1)
      end
    end

    expect(time.overall_average).to be_within(0.002).of(0.055)
    expect(time.recent_average).to be_within(0.002).of(0.101)
  end

  it 'should track total duration over multiple iterations' do
    time = ::Dsm::Time.new
    for n in 1..10
      time.measure(n, 1) do
        sleep(0.01)
      end
    end

    expect(time.total_duration).to be_within(0.002).of(0.110)
  end

  it 'should estimate remaining time based on recent average' do
    time = ::Dsm::Time.new
    for n in 1..10
      time.measure(n, 1) do
        sleep(0.01)
      end
    end
    for n in 11..20
      time.measure(n, 10) do
        sleep(0.1)
      end
    end

    expect(time.estimate[:total_seconds]).to eq(1)
  end

  it 'should calculate estimates minutes and hours from total seconds' do
    time = ::Dsm::Time.new

    time.measure(1, 3661) do
      sleep(1)
    end

    # not going to test exact seconds, because ~3600 iterations is enough
    # to cause small changes in the exact estimated seconds
    expect(time.estimate[:hours]).to eq(1)
    expect(time.estimate[:minutes]).to eq(1)
  end
end
