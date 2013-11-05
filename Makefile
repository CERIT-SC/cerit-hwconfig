FQDN=$(shell hostname -f)

# HP Scripting Toolkit for Linux 9.50
URL_HPST=https://ftp.hp.com/pub/softlib2/software1/pubsw-linux/p1221080004/v84368/hp-scripting-toolkit-linux-9.50.tar.gz

define hprcu
	DEF=`mktemp` && \
	m4 -D_SERVER_NAME_=$2 $1 | tee $$DEF && \
	util/hprcu -a -l -f $$DEF && \
	unlink $$DEF
endef

##### Utils

util/hprcu:
	curl "${URL_HPST}" | tar -C util/ --strip-components=2 --no-anchored -xzvf - hprcu

util: util/hprcu

#####

fineus%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/fineus.cerit-sc.cz.xml,$@)

hdb%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdb.cerit-sc.cz.xml,$@)

hdc%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdc.cerit-sc.cz.xml,$@)

all: $(FQDN)
	@echo 'What could be done, was done ...'
