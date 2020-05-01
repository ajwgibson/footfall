require 'rails_helper'

RSpec.describe RetrieveFootfallDataJob, type: :job do
  describe 'perform' do
    let(:service) { double }
    let(:task) { double }
    let(:d1) { { dev_id: 'a', footfall: 1, battery: 2, time: '2020-04-24T13:23:24.123Z' } }
    let(:d2) { { dev_id: 'b', footfall: 3, battery: 4, time: '2020-04-25T13:23:24.123Z' } }
    let(:d3) { { dev_id: 'b', footfall: 3, battery: 4, time: '2020-04-25T13:23:24.123Z' } }

    before(:each) do
      allow(BackgroundTask).to receive(:schedule_update_device_counters_task)
      allow(BackgroundTask).to receive(:schedule_raise_alarms_task)
      allow(DynamoDbService).to receive(:new).and_return(service)
      allow(service).to receive(:get_footfall_data).and_return([d1, d2, d3])
      allow(service).to receive(:delete_footfall_data)
      allow(task).to receive(:start)
      allow(task).to receive(:finish)
      allow(task).to receive(:update)

      RetrieveFootfallDataJob.perform_now task
    end

    it 'gets data using the DynamoDbService' do
      expect(service).to have_received(:get_footfall_data)
    end

    it 'creates a data record for each record' do
      expect(DeviceDataRecord.count).to eq(2)
      ddr = DeviceDataRecord.where(device_id: 'a').first
      expect(ddr.footfall).to eq(1)
      expect(ddr.battery).to eq(2)
      expect(ddr.recorded_at).to eq('2020-04-24T13:23:24.123Z'.to_time)
    end

    it 'uses the service to delete records' do
      expect(service).to have_received(:delete_footfall_data).with(
        { dev_id: 'a', footfall: 1, battery: 2, time: '2020-04-24T13:23:24.123Z' }
      )
      expect(service).to have_received(:delete_footfall_data).twice.with(
        { dev_id: 'b', footfall: 3, battery: 4, time: '2020-04-25T13:23:24.123Z' }
      )
    end

    it 'ignores duplicate records' do
      expect(DeviceDataRecord.count).to eq(2)
    end

    it 'starts the background task' do
      expect(task).to have_received(:start)
    end

    it 'finishes the background task' do
      expect(task).to have_received(:finish).with(:success)
    end

    it 'updates the task information' do
      expect(task).to have_received(:update).with(
        info: {
          retrieved: 3,
          additions: {
            count: 2,
            records: [
              { dev_id: 'a', footfall: 1, battery: 2, time: '2020-04-24T13:23:24.123Z' },
              { dev_id: 'b', footfall: 3, battery: 4, time: '2020-04-25T13:23:24.123Z' }
            ]
          },
          duplicates: {
            count: 1,
            records: [
              { dev_id: 'b', footfall: 3, battery: 4, time: '2020-04-25T13:23:24.123Z' }
            ]
          },
          errors: {
            count: 0,
            records: []
          }
        }
      )
    end

    it 'schedules follow up tasks' do
      expect(BackgroundTask).to have_received(:schedule_raise_alarms_task)
      expect(BackgroundTask).to have_received(:schedule_update_device_counters_task)
    end
  end
end