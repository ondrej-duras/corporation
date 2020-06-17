#!/usr/bin/env python3
##!/usr/bin/env python2
##!/usr/bin/env python3

import platform
import sys

print("Python version ..... " + str(platform.python_version()))

try:
  import colorama
  colorama.init()
  print ("\033[1;33mcolorama ANSI Terminal works !\033[m")

except:
  pass

print("Arguments:")
for arg in sys.argv:
  print(arg)

# --- end ---

