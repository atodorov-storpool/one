#!/bin/bash
#

PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH

#logger -t "reserved_resources" -- "$0 $1 //$PWD"

if [ -f ../../etc/im/kvm-probes.d/reserved_resources.conf ]; then
    source ../../etc/im/kvm-probes.d/reserved_resources.conf
fi

cgroup="${cgroup:-machine.slice}"

function count_cpus()
{
	local _list="$1" _cpu=0 _c= _arr=()
	for _c in ${_list//,/ }; do
		_arr=(${_c//-/ })
		if [ ${#_arr[@]} -eq 2 ]; then
			_cpu=$((_cpu + _arr[1] - _arr[0]))
		fi
		_cpu=$((_cpu + 1))
	done
	echo "$_cpu"
}

cg_arr=($(cgget -v -n -r memory.limit_in_bytes -r cpuset.cpus "$cgroup" -r memory.usage_in_bytes ))
ret=$?
if [ $ret = 0 ]; then
    cg_cpus=`count_cpus "${cg_arr[1]}"`
    memTotal=$(( cg_arr[0] / 1024 ))
    memUsed=$(( cg_arr[2] / 1024 ))
    memFree=$(( memTotal - memUsed ))
    echo "CGROUP_CPUS=$cg_cpus"
    echo "CGROUP_TOTALMEMORY=${memTotal:-0}"
    echo "CGROUP_USEDMEMORY=${memUsed:-0}"
    echo "CGROUP_FREEMEMORY=${memFree:-0}"
    echo "CGROUP=$cgroup"
    echo "TOTALCPU=$((cg_cpus*100))"
    echo "TOTALMEMORY=${memTotal:-0}"
    echo "USEDMEMORY=${memUsed:-0}"
    echo "FREEMEMORY=${memFree:-0}"
fi
