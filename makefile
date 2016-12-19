#
# MAKEFILE of myPL project
# 20160501, Ing. Ondrej DURAS
# ~/prog/myPL/makefile
# VERSION=2016.121901
#

PROJECT=myPL
PLATFORM=$(shell perl -e "print $$^O;")
TIMESTAMPL=$(shell perl -e "use POSIX; print(strftime(\"%Y%m%d-%H%M%S\",gmtime(time)));")
TIMESTAMPW=$(shell perl -e "use POSIX; print(strftime('%%Y%%m%%d-%%H%%M%%S',gmtime(time)));")
help:
	@echo "self      - makes a copy of project into bin/"
	@echo "install   - makes a copy of scripts into /usr/local/bin"
	@echo "backup    - creates a TAR-BALL backup"
	@echo "mybachup  - creates a TAR-BALL backup into ~/archive/"


self:
	-@make self-${PLATFORM}

self-MSWin32:
	@copy /Y PWA.pm       \usr\bin\lib\PWA.pm
	@copy /Y pwa.pl       \usr\bin\pwa.pl
	@copy /Y wrap.pl      \usr\bin\wrap.pl
	@copy /Y pm.pl        \usr\bin\pm.pl


self-linux:
	@mkdir -p             ${HOME}/bin/lib/
	@cp -v PWA.pm         ${HOME}/bin/lib/PWA.pm
	@cp -v pwa.pl         ${HOME}/bin/pwa.pl
	@cp -v pwa.pl         ${HOME}/bin/pwa
	@cp -v wrap.pl        ${HOME}/bin/wrap.pl
	@cp -v wrap.pl        ${HOME}/bin/wrap
	@cp -v pm.pl          ${HOME}/bin/pm.pl
	@cp -v pm.pl          ${HOME}/bin/pm
	@chmod -v 755 *.pl
	@chmod -v 755 ${HOME}/bin/*.pl
	@chmod -v 755 ${HOME}/bin/pwa
	@chmod -v 755 ${HOME}/bin/wrap
	@chmod -v 755 ${HOME}/bin/pm

backup:
	-@make backup-${PLATFORM}

backup-MSWin32:
	@echo ${TIMESTAMPW}
	@7z a     ..\${PROJECT}-${TIMESTAMPW}.7z *
	@dir      ..\${PROJECT}-${TIMESTAMPW}.7z

backup-linux:
	@echo ${TIMESTAMPL}
	tar -jcvf ../${PROJECT}-${TIMESTAMPL}.tar.bz2 ./
	ls -l     ../${PROJECT}-${TIMESTAMPL}.tar.bz2 ./

mybackup:
	@make mybackup-${PLATFORM}

mybackup-MSWin32:
	@echo ${TIMESTAMPW}
	@7z a       c:\usr\archive\${PROJECT}-${TIMESTAMPW}.7z *
	@md5sum     c:\usr\archive\${PROJECT}-${TIMESTAMPW}.7z
	@sha1sum    c:\usr\archive\${PROJECT}-${TIMESTAMPW}.7z 
	@dir        c:\usr\archive\${PROJECT}-${TIMESTAMPW}.7z 

mybackup-linux:
	@echo ${TIMESTAMPL}
	@tar -jcvf ${HOME}/archive/${PROJECT}-${TIMESTAMPL}.tar.bz2 ./
	@md5sum    ${HOME}/archive/${PROJECT}-${TIMESTAMPL}.tar.bz2 
	@sha1sum   ${HOME}/archive/${PROJECT}-${TIMESTAMPL}.tar.bz2 
	@ls -l     ${HOME}/archive/${PROJECT}-${TIMESTAMPL}.tar.bz2 


# --- end ---

