#!/usr/bin/ruby

while l = $stdin.gets
  l.strip!

  if />pckeyboardhack\.(.+?)<\// =~ l then
    entry = $1

    case ARGV[0]
    when 'hpp'
      print "int #{entry};\n"
    when 'cpp_SYSCTL'
      print "SYSCTL_PROC(_pckeyboardhack, OID_AUTO, #{entry}, CTLTYPE_INT|CTLFLAG_RW, &(config.#{entry}), 0, &sysctlFunc, \"I\", \"\");\n"
    when 'cpp_register'
      print "sysctl_register_oid(&sysctl__pckeyboardhack_#{entry});\n"
    when 'cpp_unregister'
      print "sysctl_unregister_oid(&sysctl__pckeyboardhack_#{entry});\n"

    when 'code_initialize', 'code_terminate', 'code_setkeycode', 'code_hpp'
      if /^keycode_(.+)/ =~ entry then
        symbol = $1
        case ARGV[0]
        when 'code_initialize'
          print "#{entry} = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::#{symbol.upcase}];\n"
        when 'code_terminate'
          print "hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::#{symbol.upcase}] = #{entry};\n"
        when 'code_setkeycode'
          print "setkeycode(hid, org_pqrs_PCKeyboardHack::KeyMapIndex::#{symbol.upcase}, org_pqrs_PCKeyboardHack::config.enable_#{symbol}, org_pqrs_PCKeyboardHack::config.keycode_#{symbol}, keycode_#{symbol});\n"
        when 'code_hpp'
          print "unsigned int keycode_#{symbol};\n"
        end
      end
    end
  end
end
