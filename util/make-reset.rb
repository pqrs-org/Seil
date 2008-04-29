#!/usr/bin/env ruby

entry = nil
while l = gets
  if /<keycode>(.+)<\/keycode>/ =~ l then
    entry = $1
  end
  if /<default>(.+)<\/default>/ =~ l then
    print "#{entry} #{$1}\n"
  end
  if /<enable>(.+)<\/enable>/ =~ l then
    print "#{$1} 0\n"
  end
end
