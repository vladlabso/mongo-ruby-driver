require 'spec_helper'

describe Mongo::Session, if: sessions_enabled? do

  let(:session) do
    authorized_client.start_session(options)
  end

  let(:options) do
    {}
  end

  describe '#initialize' do

    context 'when options are provided' do

      it 'duplicates and freezes the options' do
        expect(session.options).not_to be(options)
        expect(session.options.frozen?).to be(true)
      end
    end

    it 'sets a server session with an id' do
      expect(session.session_id).to be_a(BSON::Document)
    end

    it 'sets the cluster time to nil' do
      expect(session.cluster_time).to be(nil)
    end

    it 'sets the client' do
      expect(session.client).to be(authorized_client)
    end
  end

  describe '#advance_cluster_time' do

    let(:new_cluster_time) do
      { 'clusterTime' => BSON::Timestamp.new(0, 5) }
    end

    context 'when the session does not have a cluster time' do

      before do
        session.advance_cluster_time(new_cluster_time)
      end

      it 'sets the new cluster time' do
        expect(session.cluster_time).to eq(new_cluster_time)
      end
    end

    context 'when the session already has a cluster time' do

      context 'when the original cluster time is less than the new cluster time' do

        let(:original_cluster_time) do
          { 'clusterTime' => BSON::Timestamp.new(0, 1) }
        end

        before do
          session.instance_variable_set(:@cluster_time, original_cluster_time)
          session.advance_cluster_time(new_cluster_time)
        end

        it 'sets the new cluster time' do
          expect(session.cluster_time).to eq(new_cluster_time)
        end
      end

      context 'when the original cluster time is equal or greater than the new cluster time' do

        let(:original_cluster_time) do
          { 'clusterTime' => BSON::Timestamp.new(0, 6) }
        end

        before do
          session.instance_variable_set(:@cluster_time, original_cluster_time)
          session.advance_cluster_time(new_cluster_time)
        end

        it 'does not update the cluster time' do
          expect(session.cluster_time).to eq(original_cluster_time)
        end
      end
    end
  end

  describe 'ended?' do

    context 'when the session has not been ended' do

      it 'returns false' do
        expect(session.ended?).to be(false)
      end
    end

    context 'when the session has been ended' do

      before do
        session.end_session
      end

      it 'returns true' do
        expect(session.ended?).to be(true)
      end
    end
  end

  describe 'end_session' do

    let!(:server_session) do
      session.instance_variable_get(:@server_session)
    end

    let(:client_session_pool) do
      session.client.instance_variable_get(:@session_pool)
    end

    it 'returns the server session to the client session pool' do
      session.end_session
      expect(client_session_pool.instance_variable_get(:@queue)).to include(server_session)
    end

    context 'when #end_session is called multiple times' do

      before do
        session.end_session
      end

      it 'returns nil' do
        expect(session.end_session).to be_nil
      end
    end
  end
end
