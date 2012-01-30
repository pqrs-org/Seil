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
  :KeyMapIndex_Value => open('output/KeyMapIndex_Value.cpp.tmp', 'w'),
}

ARGV.each do |xmlpath|
  open(xmlpath) do |f|
    doc = REXML::Document.new(f)

    REXML::XPath.each(doc, '//item') do |item|
      enable = REXML::XPath.first(item, './enable')
      next if enable.nil?

      kHIDUsage = REXML::XPath.first(item, './kHIDUsage')
      next if kHIDUsage.nil?

      identifier = enable.text.gsub(/enable_/, '').upcase
      $outfile[:KeyMapIndex_Value] << "#{identifier} = #{kHIDUsage.text},\n"
    end
  end
end

$outfile.each do |key,file|
  file.close
  Converter.update_file_if_needed(file.path)
end
