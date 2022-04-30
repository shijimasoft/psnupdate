require 'net/https'
require 'uri'
require 'nokogiri'
require 'json'

# Retrieve PS3 game updates from the PSN server
class Update
  def initialize(title_id)
    @title_id = title_id
  end

  def xml_updates
    xml_uri = URI.parse format("https://a0.ww.np.dl.playstation.net/tpl/np/#{@title_id}/#{@title_id}-ver.xml")
    psn_client = Net::HTTP.new(xml_uri.host, xml_uri.port)

    # SSL context
    psn_client.use_ssl = true
    psn_client.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # PSN get request
    get = Net::HTTP::Get.new(xml_uri.request_uri)
    data = psn_client.request(get)

    data.code.to_i == 200 ? data.body : nil
  end

  # Bytes to MBytes
  def to_mb(size)
    (size.to_f / 1_000_000).round 2
  end

  def updates
    data = xml_updates
    { title_id: @title_id, title: nil, updates: [] } if data.nil?

    data = Nokogiri::XML(data)
    updates = []
    data.xpath('//package').each do |update|
      updates += [
        version: update['version'].to_f,
        min_firmware: update['ps3_system_ver'].to_f,
        size_mb: to_mb(update['size']),
        url: update['url'],
        sha1: update['sha1sum']
      ]
    end

    { title_id: @title_id, title: data.xpath('//TITLE').text, updates: updates }
  end
end
