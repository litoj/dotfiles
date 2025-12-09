#!/usr/bin/bash

if [[ -z $1 || -z $2 ]]; then
	echo "
	usage: $0 <bootid> <label> [kernel_args]
	DEBUG=1 to only print the command instead of executing
	VERBOSE=1 to include all kernel messages
	MINIMAL=1 to drop all unnecessary flags
"
	sudo efibootmgr
	exit 0
fi

id=$1
label=$2
if [[ ${label,,} == *lts* ]]; then
	suffix=-lts
fi
kcmd=$3

# root disk
root_uuid=$(findmnt -no UUID -T /)
disk=$(readlink -f /dev/disk/by-uuid/$(findmnt -no UUID -T /))
[[ $disk =~ /(nvme[0-9]+n[0-9]+|sd.) ]]
disk=/dev/${BASH_REMATCH[1]}

[[ $kcmd != *root* ]] && kcmd+=" root=UUID=$root_uuid rw"

if [[ ${MINIMAL/true/1} -eq 0 ]]; then
	# hibernation
	if [[ -f /swapfile && $kcmd != *resume_offset* ]]; then
		echo 'Finding swapfile start: sudo filefrag -v /swapfile'
		kcmd+=" resume_offset=$(sudo filefrag -v /swapfile |
			sed -nE 's/^\s*0(\S+\s+){3}([0-9]+).*$/\2/p')"
	fi
	[[ $kcmd != *resume=* && $kcmd == *resume_offset=* ]] && kcmd+=" resume=UUID=$root_uuid"

	# defaults
	kcmd+=' acpi_osi=Linux usbcore.autosuspend=5 mitigations=auto'

	# cpu-specific ucode + options
	if grep -i amd /proc/cpuinfo &>/dev/null; then
		kcmd+=" amd_pstate=active amdgpu.gpu_recovery=1 amdgpu.cwsr_enable=0" # amd_pstate.shared_mem=1
		[[ -f /boot/amd-ucode.img ]] && kcmd+=' initrd=\amd-ucode.img'
	else
		[[ -f /boot/intel-ucode.img ]] && kcmd+=' initrd=\intel-ucode.img'
	fi

	[[ ${VERBOSE/true/1} -eq 0 ]] && kcmd+=" loglevel=2 quiet"
fi

kcmd+=" initrd=\\booster-linux$suffix.img"

cmd=(efibootmgr -b $id -c -L "$label" -d "$disk" -l "/vmlinuz-linux$suffix" -u "$kcmd")
[[ $DEBUG ]] && echo "${cmd[@]}" || sudo "${cmd[@]}"

# example:
# sudo efibootmgr -b 0002 -c -L ArchVerbose -d /dev/nvme0n1 -l /vmlinuz-linux -u "root=UUID=7a3dbe65-df81-4c67-bdfc-23d440d23044 rw resume=UUID=7a3dbe65-df81-4c67-bdfc-23d440d23044 resume_offset=442368 acpi_osi=Linux usbcore.autosuspend=5 mitigations=auto amd_pstate.shared_mem=1 amd_pstate=active initrd=\\amd-ucode.img initrd=\\booster-linux.img"
