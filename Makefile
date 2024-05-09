PROGRAM             = nomadbsd-chusr
PYLUPDATE           = pylupdate6
PREFIX             ?= /usr
BINDIR              = ${PREFIX}/bin
DATADIR             = ${PREFIX}/share/${PROGRAM}
APPSDIR             = ${PREFIX}/share/applications
INSTALL_TARGETS     = ${PROGRAM} ${PROGRAM}.desktop translate
BSD_INSTALL_DATA   ?= install -m 0644
BSD_INSTALL_SCRIPT ?= install -m 555
LRELEASE           ?= /usr/local/lib/qt6/bin/lrelease

all: ${PROGRAM}.py

${PROGRAM}.py: ${PROGRAM}.in
	sed -e "s|@LOCALE_PATH@|${DATADIR}|; s|@PROGRAM@|${PROGRAM}|g" \
		${PROGRAM}.in > ${PROGRAM}.py
	chmod a+x ${PROGRAM}.py

${PROGRAM}.desktop: ${PROGRAM}.desktop.in
	sed -e "s|@PROGRAM@|${BINDIR}/${PROGRAM}|g" \
		${PROGRAM}.desktop.in > ${PROGRAM}.desktop

lupdate: ${PROGRAM}.py
	for i in locale/*.ts; do \
		${PYLUPDATE} --no-obsolete --ts $$i ${PROGRAM}.py; done

translate:
	for i in locale/*.ts; do \
		${LRELEASE} $$i -qm $${i%ts}qm; done

install: ${INSTALL_TARGETS}
	${BSD_INSTALL_SCRIPT} ${PROGRAM}.py ${DESTDIR}${BINDIR}/${PROGRAM}
	if [ ! -d ${DATADIR} ]; then mkdir -p ${DATADIR}; fi
	if [ ! -d ${APPSDIR} ]; then mkdir -p ${APPSDIR}; fi
	${BSD_INSTALL_DATA} ${PROGRAM}.desktop ${APPSDIR}
	for i in locale/*.qm; do \
		${BSD_INSTALL_DATA} $$i ${DATADIR}; done

clean:
	-rm -f ${PROGRAM}.py
	-rm -f ${PROGRAM}.desktop
	-rm -f locale/*.qm

