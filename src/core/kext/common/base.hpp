#ifndef BASE_HPP
#define BASE_HPP

#include <mach/mach_types.h>
#include <IOKit/hidsystem/ev_keymap.h>
#define protected public // A hack for access private member of IOHIKeyboard
#include <IOKit/hidsystem/IOHIKeyboard.h>
// YY:07/12/05:included from Leopard or Tiger folder according to $USER_HEADER_SEARCH_PATHS in Build tab of Project setting
#include "IOHIDKeyboard.h"
// YY:07/12/05
#undef protected

#define IOLOG_ERROR(...)  IOLog("PCKeyboardHack --Error-- " __VA_ARGS__)
#define IOLOG_INFO(...)   IOLog("PCKeyboardHack --Info-- "  __VA_ARGS__)
#define IOLOG_WARN(...)   IOLog("PCKeyboardHack --Warn-- "  __VA_ARGS__)

#endif
