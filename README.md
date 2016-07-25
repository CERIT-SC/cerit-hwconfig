# HW configurations

[![Build Status](https://travis-ci.org/CERIT-SC/cerit-hwconfig.png?branch=master)](https://travis-ci.org/CERIT-SC/cerit-hwconfig)

Repository contains (default) configurations for various
components in CERIT-SC's infrastructure.

## Usage

Have production IPMI credentials in `config.mk`. Example:

```
IPMI_USER=ADMIN
IPMI_PSWD=mysecretpassword
```

Download all required utilities.

```bash
make util
```

### Configure BIOS

Example:

```bash
make zebra1.priv.cerit-sc.cz.bios
make hdc1.priv.cerit-sc.cz.bios
```

### Configure IPMI (iLO, IMM)

Example:

```bash
make zebra1.priv.cerit-sc.cz.ipmi
make hdc1.priv.cerit-sc.cz.ipmi
```

***

CERIT Scientific Cloud, <support@cerit-sc.cz>
