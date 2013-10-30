require './spec/spec_helper'

describe Request do
  describe '.parse_headers' do
    context 'a couple of headers' do
      let(:plain_headers) do
        "HEADER_1 VALUE_1\nHEADER_2 VALUE_2"
      end

      let(:parsed_headers) do
        Request.parse_headers(plain_headers)
      end

      it 'returns a hash' do
        expect(parsed_headers).to be_a_kind_of Hash
      end

      it 'returns a hash with the HEADER_1/VALUE_1 key/value pair' do
        expect(parsed_headers['HEADER_1']).to eq 'VALUE_1'
      end

      it 'returns a hash with the HEADER_2/VALUE_2 key/value pair' do
        expect(parsed_headers['HEADER_2']).to eq 'VALUE_2'
      end
    end

    context 'with four headers' do
      let(:plain_headers) do
        "HEADER_1 VALUE_1\nHEADER_2 VALUE_2\nHEADER_3 VALUE_3\nHEADER_4 VALUE_4"
      end

      let(:parsed_headers) do
        Request.parse_headers(plain_headers)
      end

      it 'returns a hash' do
        expect(parsed_headers).to be_a_kind_of Hash
      end

      it 'returns a hash with the HEADER_1/VALUE_1 key/value pair' do
        expect(parsed_headers['HEADER_1']).to eq 'VALUE_1'
      end

      it 'returns a hash with the HEADER_2/VALUE_2 key/value pair' do
        expect(parsed_headers['HEADER_2']).to eq 'VALUE_2'
      end
    end
  end

  describe '.parse' do
    context 'three headers and plan text body' do
      let(:plain_request) do
        [
          [
            'HEADER-1 VALUE-1',
            'HEADER-2 VALUE-2',
            'HEADER-3 VALUE-3'
          ].join("\n"),
          'This is the body of the request'
        ].join("\n\n") + "\x00"
      end

      let(:request) do
        Request.parse(plain_request)
      end

      it 'returns a request object' do
        expect(request).to be_a_kind_of Request
      end

      it 'sets the proper headers' do
        expect(request.headers['HEADER-1']).to eq 'VALUE-1'
        expect(request.headers['HEADER-2']).to eq 'VALUE-2'
        expect(request.headers['HEADER-3']).to eq 'VALUE-3'
      end

      it 'sets the proper body' do
        expect(request.body).to eq 'This is the body of the request'
      end
    end
  end

  describe '#encoded_headers' do
    let(:request) do
      Request.new.tap do |r|
        r.headers = {
          'HEADER-1' => 'VALUE-1',
          'HEADER-2' => 'VALUE-2',
          'HEADER-3' => 'VALUE-3'
        }
      end
    end

    it 'properly encodes the headers' do
      expect(request.encoded_headers).to eq "HEADER-1 VALUE-1\nHEADER-2 VALUE-2\nHEADER-3 VALUE-3"
    end
  end

  describe '#to_s' do
    let(:request) do
      Request.new.tap do |r|
        r.headers = {
          'HEADER-1' => 'VALUE-1',
          'HEADER-2' => 'VALUE-2'
        }
        r.body = 'The body'
      end
    end

    it 'encodes the request as a string' do
      expect(request.to_s).to eq "HEADER-1 VALUE-1\nHEADER-2 VALUE-2\n\nThe body\x00"
    end
  end
end
