ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += libpng16
LIBPNG16_VERSION := 1.6.37
DEB_LIBPNG16_V   ?= $(LIBPNG16_VERSION)

libpng16-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG16_VERSION)/libpng-$(LIBPNG16_VERSION).tar.xz
	$(call EXTRACT_TAR,libpng-$(LIBPNG16_VERSION).tar.xz,libpng-$(LIBPNG16_VERSION),libpng16)

ifneq ($(wildcard $(BUILD_WORK)/libpng16/.build_complete),)
libpng16:
	@echo "Using previously built libpng16."
else
libpng16: libpng16-setup
	cd $(BUILD_WORK)/libpng16 && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr
	+$(MAKE) -C $(BUILD_WORK)/libpng16
	+$(MAKE) -C $(BUILD_WORK)/libpng16 install \
		DESTDIR=$(BUILD_STAGE)/libpng16
	+$(MAKE) -C $(BUILD_WORK)/libpng16 install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libpng16/.build_complete
endif

libpng16-package: libpng16-stage
	# libpng16.mk Package Structure
	rm -rf $(BUILD_DIST)/libpng16-{16,dev,tools}
	mkdir -p $(BUILD_DIST)/libpng16-16/usr/lib \
		$(BUILD_DIST)/libpng16-dev/usr/{bin,lib} \
		$(BUILD_DIST)/libpng16-tools/usr/bin
	
	# libpng16.mk Prep libpng16-16
	cp -a $(BUILD_STAGE)/libpng16/usr/lib/libpng16.16.dylib $(BUILD_DIST)/libpng16-16/usr/lib
	
	# libpng16.mk Prep libpng16-dev
	cp -a $(BUILD_STAGE)/libpng16/usr/bin/*-config $(BUILD_DIST)/libpng16-dev/usr/bin
	cp -a $(BUILD_STAGE)/libpng16/usr/lib/!(libpng16.16.dylib) $(BUILD_DIST)/libpng16-dev/usr/lib
	cp -a $(BUILD_STAGE)/libpng16/usr/include $(BUILD_DIST)/libpng16-dev/usr
	cp -a $(BUILD_STAGE)/libpng16/usr/share $(BUILD_DIST)/libpng16-dev/usr

	# libpng16.mk Prep libpng16-tools
	cp -a $(BUILD_STAGE)/libpng16/usr/bin/!(*-config) $(BUILD_DIST)/libpng16-tools/usr/bin

	# libpng16.mk Sign
	$(call SIGN,libpng16-16,general.xml)
	$(call SIGN,libpng16-tools,general.xml)
	
	# libpng16.mk Make .debs
	$(call PACK,libpng16-16,DEB_LIBPNG16_V)
	$(call PACK,libpng16-dev,DEB_LIBPNG16_V)
	$(call PACK,libpng16-tools,DEB_LIBPNG16_V)
	
	# libpng16.mk Build cleanup
	rm -rf $(BUILD_DIST)/libpng16-{16,dev,tools}

.PHONY: libpng16 libpng16-package
