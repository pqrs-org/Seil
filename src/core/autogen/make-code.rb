#!/usr/bin/ruby

require 'rexml/document'

class Converter
  def self.update_file_if_needed(tmpfilepath)
    targetfilepath = tmpfilepath.gsub(/\.tmp$/, '')

    if (! FileTest.exist?(targetfilepath)) or (IO.read(tmpfilepath) != IO.read(targetfilepath)) then
      File.rename(tmpfilepath, targetfilepath)
    else
      File.unlink(tmpfilepath)
    end
  end
end

# ============================================================
$outfile = {
  :BRIDGE_KEY_INDEX                  => open('output/BRIDGE_KEY_INDEX.h.tmp', 'w'),
  :KeyMapIndex_Value                 => open('output/KeyMapIndex_Value.hpp.tmp', 'w'),
  :KeyMapIndex_bridgeKeyindexToValue => open('output/KeyMapIndex_bridgeKeyindexToValue.hpp.tmp', 'w'),
  :bridgeconfig_config               => open('output/bridgeconfig_config.h.tmp', 'w'),
  :setDefault                        => open('output/setDefault.h.tmp', 'w'),
}

ARGV.each do |xmlpath|
  open(xmlpath) do |f|
    doc = REXML::Document.new(f)

    REXML::XPath.each(doc, '//item') do |item|
      enable = REXML::XPath.first(item, './enable')
      next if enable.nil?

      keycode = REXML::XPath.first(item, './keycode')
      next if keycode.nil?

      kHIDUsage = REXML::XPath.first(item, './kHIDUsage')
      next if kHIDUsage.nil?

      default = REXML::XPath.first(item, './default')
      next if default.nil?

      identifier = enable.text.gsub(/enable_/, '').upcase
      $outfile[:BRIDGE_KEY_INDEX] << "BRIDGE_KEY_INDEX_#{identifier},\n"
      $outfile[:KeyMapIndex_Value] << "#{identifier} = #{kHIDUsage.text},\n"
      $outfile[:KeyMapIndex_bridgeKeyindexToValue] << "case BRIDGE_KEY_INDEX_#{identifier}: return #{identifier};\n"

      $outfile[:bridgeconfig_config] << "bridgeconfig.config[BRIDGE_KEY_INDEX_#{identifier}].enabled = [preferencesManager_ value:@\"#{enable.text}\"];\n"
      $outfile[:bridgeconfig_config] << "bridgeconfig.config[BRIDGE_KEY_INDEX_#{identifier}].keycode = [preferencesManager_ value:@\"#{keycode.text}\"];\n"

      $outfile[:setDefault] << "[default_ setObject:[NSNumber numberWithInt:#{default.text}] forKey:@\"#{keycode.text}\"];\n"
    end
  end
end

$outfile.each do |key,file|
  file.close
  Converter.update_file_if_needed(file.path)
end
