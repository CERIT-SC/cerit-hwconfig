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
	mkdir -p util/
	curl "${URL_HPST}" | tar -C util/ --strip-components=2 \
		--occurrence=1 --no-anchored -xzvf - hprcu
	@echo "Download OK: $@"

util: util/hprcu


#####

fineus%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/fineus.cerit-sc.cz.xml,$@)

hdb%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdb.cerit-sc.cz.xml,$@)

hdc%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdc.cerit-sc.cz.xml,$@)

# old HP ProLiant DL980 *G7* requires obsolete 'conrep' tool
zewura1.cerit-sc.cz zewura2.cerit-sc.cz zewura3.cerit-sc.cz\
zewura4.cerit-sc.cz zewura5.cerit-sc.cz zewura6.cerit-sc.cz\
zewura7.cerit-sc.cz zewura8.cerit-sc.cz: bios/hp_zewura.cerit-sc.cz.rbsu
	@echo 'BIOS setup is manuall process, use BIOS RBSU'
	@exit 1

clean:
	rm -f util/*

test: util

all: $(FQDN)
	@echo 'What could be done, was done ...'
