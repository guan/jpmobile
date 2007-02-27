require File.dirname(__FILE__)+'/helper'

class SoftbankTest < Test::Unit::TestCase
  # SoftBank, 端末種別の識別
  def test_softbank_910t
    req = request_with_ua("SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
    assert_equal(true, req.mobile?)
    assert_instance_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_equal(nil, req.mobile.position)
    assert_equal("000000000000000", req.mobile.ident)
  end

  # Vodafone, 端末種別の識別
  def test_vodafone_v903t
    req = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
    assert_equal(true, req.mobile?)
    assert_instance_of(Jpmobile::Mobile::Vodafone, req.mobile)
    assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_equal(nil, req.mobile.position)
    assert_equal(nil, req.mobile.ident)
  end

  # Vodafone, 端末種別の識別
  def test_vodafone_v903sh
    req = request_with_ua("Vodafone/1.0/V903SH/SHJ001/SN000000000000000 Browser/UP.Browser/7.0.2.1 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0")
    assert_equal(true, req.mobile?)
    assert_instance_of(Jpmobile::Mobile::Vodafone, req.mobile)
    assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_equal("000000000000000", req.mobile.serial_number)
    assert_equal("000000000000000", req.mobile.ident)
    assert_equal(nil, req.mobile.position)
  end

  # J-PHONE, 端末種別の識別
  def test_jphone_v603sh
    req = request_with_ua("J-PHONE/4.3/V603SH/SNXXXX0000000 SH/0007aa Profile/MIDP-1.0 Configuration/CLDC-1.0 Ext-Profile/JSCL-1.3.2")
    assert_equal(true, req.mobile?)
    assert_instance_of(Jpmobile::Mobile::Jphone, req.mobile)
    assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_equal("XXXX0000000", req.mobile.serial_number)
    assert_equal("XXXX0000000", req.mobile.ident)
    assert_equal(nil, req.mobile.position)
  end

  # J-PHONE, 端末種別の識別
  def test_jphone_v301d
    req = request_with_ua("J-PHONE/3.0/V301D")
    assert_equal(true, req.mobile?)
    assert_instance_of(Jpmobile::Mobile::Jphone, req.mobile)
    assert_kind_of(Jpmobile::Mobile::Softbank, req.mobile)
    assert_equal(nil, req.mobile.serial_number)
    assert_equal(nil, req.mobile.position)
  end

  # J-PHONE
  # http://kokogiko.net/wiki.cgi?page=vodafone%A4%C7%A4%CE%B0%CC%C3%D6%BC%E8%C6%C0%CA%FD%CB%A1
  def test_jphone_antenna
    req = request_with_ua("J-PHONE/3.0/V301D",
                          "HTTP_X_JPHONE_GEOCODE"=>"353840%1A1394440%1A%93%8C%8B%9E%93s%8D%60%8B%E6%8E%C5%82T%92%9A%96%DA")
    assert_in_delta(35.64768482, req.mobile.position.lat, 1e-4)
    assert_in_delta(139.7412141, req.mobile.position.lon, 1e-4)
    assert_equal("東京都港区芝５丁目", req.mobile.position.options["address"])
  end

  # J-PHONE 位置情報なし
  def test_jphone_antenna_empty
    req = request_with_ua("J-PHONE/3.0/V301D",
                          "HTTP_X_JPHONE_GEOCODE"=>"0000000%1A0000000%1A%88%CA%92%75%8F%EE%95%F1%82%C8%82%B5")
    assert_equal(nil, req.mobile.position)
  end

  # Vodafone 3G, wgs84, gps
  def test_vodafone_gps
    req = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"QUERY_STRING"=>"pos=N43.3.18.42E141.21.1.88&geo=wgs84&x-acr=1"})
    assert_in_delta(43.05511667, req.mobile.position.lat, 1e-7)
    assert_in_delta(141.3505222, req.mobile.position.lon, 1e-7)
    assert_equal("N43.3.18.42E141.21.1.88", req.mobile.position.options["pos"])
    assert_equal("wgs84", req.mobile.position.options["geo"])
    assert_equal("1", req.mobile.position.options["x-acr"])
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_softbank_valid_ip_address
    req = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"REMOTE_ADDR"=>"202.179.204.1"})
    assert_equal(req.mobile.valid_ip?, true)
  end

  # 正しいIPアドレス空間からのアクセスを判断できるか。
  def test_jphone_valid_ip_address
    req = request_with_ua("J-PHONE/3.0/V301D",
                          {"REMOTE_ADDR"=>"202.179.204.1"})
    assert_equal(req.mobile.valid_ip?, true)
  end

  # 正しくないIPアドレス空間からのアクセスを判断できるか。
  def test_softbank_ip_address
    req = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0",
                          {"REMOTE_ADDR"=>"127.0.0.1"})
    assert_equal(req.mobile.valid_ip?, false)
  end
end
