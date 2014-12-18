FQDN=$(shell hostname -f)

# HP Scripting Toolkit for Linux 9.50
URL_HPST=https://ftp.hp.com/pub/softlib2/software1/pubsw-linux/p1221080004/v84368/hp-scripting-toolkit-linux-9.50.tar.gz

# IBM Advanced Settings Utility 9.63
#URL_ASU=https://delivery04.dhe.ibm.com/sar/CMA/XSA/04sjw/0/ibm_utl_asu_asut86d-9.63_linux_i386.tgz
URL_ASU=https://delivery04.dhe.ibm.com/sar/CMA/XSA/04sjz/0/ibm_utl_asu_asut86d-9.63_linux_x86-64.tgz

define hprcu
	DEF=`mktemp` && \
	m4 -D_SERVER_NAME_=$2 $1 | tee $$DEF && \
	util/hprcu -a -l -f $$DEF && \
	unlink $$DEF
endef


all: $(FQDN)
	@echo 'What could be done, was done ...'

test: util

clean:
	rm -f util/*

### Utils

util/hprcu:
	mkdir -p util/
	curl "${URL_HPST}" | tar -C util/ --strip-components=2 \
		--occurrence=1 --no-anchored -xzvf - hprcu
	@echo "Download OK: $@"

util/asu64:
	mkdir -p util/
	curl "${URL_ASU}" | tar -C util/ \
		--occurrence=1 --no-anchored -xzv \
		asu64
	@echo "Download OK: $@"

util: util/hprcu util/asu64

### Machines

fineus%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/fineus.cerit-sc.cz.xml,$@)

hdb%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdb.cerit-sc.cz.xml,$@)

hdc%.cerit-sc.cz: util/hprcu
	@$(call hprcu,bios/hdc.cerit-sc.cz.xml,$@)

# old HP ProLiant DL980 *G7* requires obsolete 'conrep' tool
zewura1.cerit-sc.cz zewura2.cerit-sc.cz zewura3.cerit-sc.cz\
zewura4.cerit-sc.cz zewura5.cerit-sc.cz zewura6.cerit-sc.cz\
zewura7.cerit-sc.cz zewura8.cerit-sc.cz: bios/zewura.cerit-sc.cz.rbsu
	@echo 'BIOS setup is manuall process, use BIOS RBSU'
	@exit 1
