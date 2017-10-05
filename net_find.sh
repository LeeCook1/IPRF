#!/bin/bash
find_ip () 
{ 
    /sbin/ifconfig | /bin/grep --color=auto -A 1 -e $(/sbin/route | /bin/grep default | /usr/bin/awk '{print $8}' ) | /bin/grep --color=auto inet | /usr/bin/awk '{print $2}' | /usr/bin/awk -F':' '{print $2}'
}

find_mask () 
{ 
    /sbin/ifconfig | /bin/grep --color=auto -A 1 -e $(/sbin/route | /bin/grep default | /usr/bin/awk '{print $8}' ) | /usr/bin/awk -F 'Mask:' '{print $2}'
}

find_base () 
{ 
    ip=($(find_ip | /bin/sed 's/\./ /g'));
    mask=($(find_mask | /bin/sed 's/\./ /g'));
    net_ip_rev="";
    for i in {0..3};
    do
        if ! ((255 - ${mask[$i] })); then
            net_ip_rev=${ip[$i]}.$net_ip_rev;
        else
            net_ip_rev=$((${mask[$i]} & ${ip[$i]})).$net_ip_rev;
        fi;
    done;
    /bin/echo $net_ip_rev | /usr/bin/awk -F'.' '{print $4"."$3"."$2"."$1}'
}
find_max () 
{ 
    ip=($(find_base | /bin/sed 's/\./ /g'));
    mask=($(find_mask | /bin/sed 's/\./ /g'));
    ip_ranger=();
    for i in {0..3};
    do
        ip_ranger+=($((255 - ${mask[$i]})));
        ip_ranger[$i]=$((${ip_ranger[$i]} + ${ip[$i]}));
    done;
    /bin/echo ${ip_ranger[@]} | /bin/sed 's/ /\./g'
}
find_fullnet () 
{ 
    base_ip=($(find_base | /bin/sed 's/\./ /g'));
    max_ip=($(find_max | /bin/sed 's/\./ /g'));
    str="";
    for i in {0..3};
    do
        str=$str" {"${base_ip[$i]}".."${max_ip[$i]}"}";
    done;
    /bin/echo "$str" | /usr/bin/cut -c2- 
}

shuf_net()
{
	block_count=($(find_fullnet))
	tmpfile=$(mktemp /tmp/temp_XXXX)
	for a in $(eval /bin/echo ${block_count[0]});
	do
		for b in $(eval /bin/echo ${block_count[1]});
		do
			eval /bin/echo $a.$b.${block_count[2]}.${block_count[3]} | /usr/bin/tr " " "\n" >> $tmpfile;
		done;
	done;

	/usr/bin/shuf $tmpfile -o $tmpfile 
	/bin/echo $tmpfile
}

shuf_net

