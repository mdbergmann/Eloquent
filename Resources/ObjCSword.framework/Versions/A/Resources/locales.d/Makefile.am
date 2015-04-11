swlocaledir = $(top_srcdir)/locales.d

localeDATA = $(swlocaledir)/*.conf

EXTRA_DIST += $(localeDATA)

localedatadir = $(pkgdatadir)/locales.d

installlocaleDATA: $(localeDATA)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(localedatadir)
	@list='$(localeDATA)'; for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f="`echo $$p | sed -e 's|^.*/||'`"; \
	  echo " $(INSTALL_DATA) $$d$$p $(DESTDIR)$(localedatadir)/$$f"; \
	  $(INSTALL_DATA) $$d$$p $(DESTDIR)$(localedatadir)/$$f; \
	done

uninstalllocaleDATA:
	@$(NORMAL_UNINSTALL)
	@list='$(localeDATA)'; for p in $$list; do \
	  f="`echo $$p | sed -e 's|^.*/||'`"; \
	  echo " rm -f $(DESTDIR)$(localedatadir)/$$f"; \
	  rm -f $(DESTDIR)$(localedatadir)/$$f; \
	done

