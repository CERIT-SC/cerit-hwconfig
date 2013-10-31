FQDN=$(shell hostname -f)

define hprcu
	DEF=`mktemp` && \
	m4 -D_SERVER_NAME_=$2 $1 | tee $$DEF && \
	util/hprcu -a -l -f $$DEF && \
	unlink $$DEF
endef

#####

fineus%.cerit-sc.cz:
	@$(call hprcu,bios/fineus.cerit-sc.cz.xml,$@)

hdb%.cerit-sc.cz:
	@$(call hprcu,bios/hdb.cerit-sc.cz.xml,$@)

hdc%.cerit-sc.cz:
	@$(call hprcu,bios/hdc.cerit-sc.cz.xml,$@)

all: $(FQDN)
	@echo 'What could be done, was done ...'
