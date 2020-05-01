require 'rails_helper'

RSpec.describe BackgroundTask, type: :model do
  describe 'BackgroundTask' do
    it 'has a valid default factory' do
      expect(FactoryBot.build(:default_background_task)).to be_valid
    end
  end

  # VALIDATION
  describe 'a valid background task' do
    it 'has a task type' do
      expect(FactoryBot.build(:default_background_task, task_type: nil)).not_to be_valid
    end
    it 'has a status' do
      expect(FactoryBot.build(:default_background_task, status: nil)).not_to be_valid
    end
    it 'has a outcome' do
      expect(FactoryBot.build(:default_background_task, outcome: nil)).not_to be_valid
    end
  end

  # SCOPES
  describe 'scope:with_status' do
    before(:each) do
      @a = FactoryBot.create(:default_background_task)
      @b = FactoryBot.create(:running_background_task)
    end
    it 'includes background tasks with the correct status' do
      filtered = BackgroundTask.with_status(:running)
      expect(filtered).to     include(@b)
      expect(filtered).not_to include(@a)
    end
  end

  describe 'scope:with_outcome' do
    before(:each) do
      @a = FactoryBot.create(:finished_background_task, outcome: :unknown)
      @b = FactoryBot.create(:finished_background_task, outcome: :success)
    end
    it 'includes background tasks with the correct outcome' do
      filtered = BackgroundTask.with_outcome(:unknown)
      expect(filtered).to     include(@a)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:with_task_type' do
    before(:each) do
      @a = FactoryBot.create(:default_background_task, task_type: :retrieve_footfall_data)
      @b = FactoryBot.create(:default_background_task, task_type: :raise_alarms)
    end
    it 'includes records where the background task type equals the value' do
      filtered = BackgroundTask.with_task_type(:retrieve_footfall_data)
      expect(filtered).to     include(@a)
      expect(filtered).not_to include(@b)
    end
  end

  # METHODS etc

  describe 'self.selectable_task_types' do
    it 'returns the task type values as an array suitable for a select list' do
      expect(BackgroundTask.selectable_task_types).to eq([
        ['Raise alarms', 'raise_alarms'],
        ['Retrieve footfall data', 'retrieve_footfall_data'],
        ['Update device counters', 'update_device_counters']
      ])
    end
  end

  describe 'self.selectable_statuses' do
    it 'returns the status values as an array suitable for a select list' do
      expect(BackgroundTask.selectable_statuses).to eq([
        ['Scheduled', 'scheduled'],
        ['Running',   'running'],
        ['Finished',  'finished']
      ])
    end
  end

  describe 'self.selectable_outcomes' do
    it 'returns the outcome values as an array suitable for a select list' do
      expect(BackgroundTask.selectable_outcomes).to eq([
        ['Unknown', 'unknown'],
        ['Success', 'success'],
        ['Error',   'error']
      ])
    end
  end

  describe '#schedule_task' do
    context 'for a task of type retrieve_footfall_data' do
      let(:task) { FactoryBot.build(:default_background_task, task_type: :retrieve_footfall_data) }
      before(:each) do
        allow(RetrieveFootfallDataJob).to receive(:perform_later).with(task)
      end
      it 'schedules a retrieve footfall data job' do
        expect(RetrieveFootfallDataJob).to receive(:perform_later).with(task)
        task.schedule_task
      end
    end

    context 'for a task of type raise_alarms' do
      let(:task) { FactoryBot.build(:default_background_task, task_type: :raise_alarms) }
      before(:each) do
        allow(RaiseAlarmsJob).to receive(:perform_later).with(task)
      end
      it 'schedules a retrieve footfall data job' do
        expect(RaiseAlarmsJob).to receive(:perform_later).with(task)
        task.schedule_task
      end
    end

    context 'for a task of type update_device_counters' do
      let(:task) { FactoryBot.build(:default_background_task, task_type: :update_device_counters) }
      before(:each) do
        allow(UpdateDeviceCountersJob).to receive(:perform_later).with(task)
      end
      it 'schedules a retrieve footfall data job' do
        expect(UpdateDeviceCountersJob).to receive(:perform_later).with(task)
        task.schedule_task
      end
    end
  end

  describe '#start' do
    let(:task) { FactoryBot.create(:default_background_task) }
    before(:each) do
      task.start
      task.reload
    end
    it 'changes the status to running' do
      expect(task.running?).to be_truthy
    end
    it 'sets the started_at' do
      expect(task.started_at).to be_within(2.seconds).of(Time.now)
    end
  end

  describe '#finish' do
    let(:task) { FactoryBot.create(:default_background_task) }
    before(:each) do
      task.finish(:success)
      task.reload
    end
    it 'changes the status to finished' do
      expect(task.finished?).to be_truthy
    end
    it 'applies the outcome' do
      expect(task.success?).to be_truthy
    end
    it 'sets the finished_at' do
      expect(task.finished_at).to be_within(2.seconds).of(Time.now)
    end
  end
end
