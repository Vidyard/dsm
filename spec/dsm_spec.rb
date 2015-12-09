require 'spec_helper'
require 'stringio'

describe 'migrate_data' do
  include Dsm

  before(:all) do
    connect!
  end

  before(:each) do
    clean_test_table
  end

  it 'should set start and end if to 0 and max id if not specified' do
    sql_data = []
    for i in 1..100 do
      sql_data << "(1, 'vy#{i}')"
    end

    connection.execute("
      INSERT INTO persons
        (data, data2)
      VALUES #{sql_data.join(',')}")

    allow_any_instance_of(::Dsm::Time).to receive(:total_duration).and_return(5.1234)
    allow_any_instance_of(::Dsm::Time).to receive(:overall_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:recent_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:estimate).and_return({:hours => 0, :minutes => 12, :seconds => 13, :total_seconds => 733})

    output = StringIO.new
    count = 0
    range_end_points = []
    ::Dsm.migrate_data(:persons, :stride => 10, :throttle => 50, :output => output) do |begin_range, end_range|
      range_end_points << begin_range
      range_end_points << end_range
      count += 1
    end

    expect(count).to eq(10)
    expect(range_end_points).to eq([1, 10, 11, 20, 21, 30, 31, 40, 41, 50, 51, 60, 61, 70, 71, 80, 81, 90, 91, 100])
    expect(output.string).to eq("Migrating data for table: persons\nStride: 10\nThrottle: 50 ms (included in averages)\nStart Id: 1\nEnd Id: 100\n\r10% complete [1/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r20% complete [2/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r30% complete [3/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r40% complete [4/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r50% complete [5/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r60% complete [6/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r70% complete [7/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r80% complete [8/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r90% complete [9/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r100% complete [10/10] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13 \n \nDONE!\n")
  end

  it 'should obey start and end id when set' do
    sql_data = []
    for i in 1..100 do
      sql_data << "(1, 'vy#{i}')"
    end

    connection.execute("
      INSERT INTO persons
        (data, data2)
      VALUES #{sql_data.join(',')}")

    allow_any_instance_of(::Dsm::Time).to receive(:total_duration).and_return(5.1234)
    allow_any_instance_of(::Dsm::Time).to receive(:overall_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:recent_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:estimate).and_return({:hours => 0, :minutes => 12, :seconds => 13, :total_seconds => 733})

    output = StringIO.new
    count = 0
    range_end_points = []
    ::Dsm.migrate_data(:persons, :stride => 10, :throttle => 50, :start_id => 3, :end_id => 12, :desc => 'TEST DESCRIPTION', :output => output) do |begin_range, end_range|
      range_end_points << begin_range
      range_end_points << end_range
      count += 1
    end

    expect(count).to eq(1)
    expect(range_end_points).to eq([3, 12])
    expect(output.string).to eq("TEST DESCRIPTION\nStride: 10\nThrottle: 50 ms (included in averages)\nStart Id: 3\nEnd Id: 12\n\r100% complete [1/1] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13 \n \nDONE!\n")
  end

  it 'should obey start and end id when not nicely divisible by stride' do
    sql_data = []
    for i in 1..30 do
      sql_data << "(1, 'vy#{i}')"
    end

    connection.execute("
      INSERT INTO persons
        (data, data2)
      VALUES #{sql_data.join(',')}")

    allow_any_instance_of(::Dsm::Time).to receive(:total_duration).and_return(5.1234)
    allow_any_instance_of(::Dsm::Time).to receive(:overall_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:recent_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:estimate).and_return({:hours => 0, :minutes => 12, :seconds => 13, :total_seconds => 733})

    output = StringIO.new
    count = 0
    range_end_points = []
    ::Dsm.migrate_data(:persons, :stride => 10, :throttle => 50, :start_id => 1, :end_id => 11, :output => output) do |begin_range, end_range|
      range_end_points << begin_range
      range_end_points << end_range
      count += 1
    end

    expect(count).to eq(2)
    expect(range_end_points).to eq([1, 10, 11, 11])
    expect(output.string).to eq("Migrating data for table: persons\nStride: 10\nThrottle: 50 ms (included in averages)\nStart Id: 1\nEnd Id: 11\n\r50% complete [1/2] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13\r100% complete [2/2] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13 \n \nDONE!\n")
  end

  it 'should obey start and end id stride greater than end_id - start_id' do
    sql_data = []
    for i in 1..30 do
      sql_data << "(1, 'vy#{i}')"
    end

    connection.execute("
      INSERT INTO persons
        (data, data2)
      VALUES #{sql_data.join(',')}")

    allow_any_instance_of(::Dsm::Time).to receive(:total_duration).and_return(5.1234)
    allow_any_instance_of(::Dsm::Time).to receive(:overall_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:recent_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:estimate).and_return({:hours => 0, :minutes => 12, :seconds => 13, :total_seconds => 733})

    output = StringIO.new
    count = 0
    range_end_points = []
    ::Dsm.migrate_data(:persons, :stride => 10, :throttle => 50, :start_id => 3, :end_id => 5, :output => output) do |begin_range, end_range|
      range_end_points << begin_range
      range_end_points << end_range
      count += 1
    end

    expect(count).to eq(1)
    expect(range_end_points).to eq([3, 5])
    expect(output.string).to eq("Migrating data for table: persons\nStride: 10\nThrottle: 50 ms (included in averages)\nStart Id: 3\nEnd Id: 5\n\r100% complete [1/1] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13 \n \nDONE!\n")
  end

  it 'should output range when error is raised' do
    sql_data = []
    for i in 1..20 do
      sql_data << "(1, 'vy#{i}')"
    end

    connection.execute("
      INSERT INTO persons
        (data, data2)
      VALUES #{sql_data.join(',')}")

    allow_any_instance_of(::Dsm::Time).to receive(:total_duration).and_return(5.1234)
    allow_any_instance_of(::Dsm::Time).to receive(:overall_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:recent_average).and_return(0.4567)
    allow_any_instance_of(::Dsm::Time).to receive(:estimate).and_return({:hours => 0, :minutes => 12, :seconds => 13, :total_seconds => 733})

    output = StringIO.new
    count = 0
    range_end_points = []
    expect{
      ::Dsm.migrate_data(:persons, :stride => 10, :throttle => 50, :start_id => 1, :end_id => 20, :output => output) do |begin_range, end_range|
        range_end_points << begin_range
        range_end_points << end_range
        count += 1
        raise "Cody, do you actually read my specs during code review?" if count == 2
      end
    }.to raise_error(StandardError)

    expect(count).to eq(2)
    expect(output.string).to eq("Migrating data for table: persons\nStride: 10\nThrottle: 50 ms (included in averages)\nStart Id: 1\nEnd Id: 20\n\r50% complete [1/2] | Recent Mean: 0.457s | Mean: 0.457s | Runtime: 5.123s | Remaining: 0:12:13Error in range 11 to 20\n")
  end
end
