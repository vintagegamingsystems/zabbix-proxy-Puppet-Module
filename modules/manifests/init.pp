# Zabbix Proxy module
class zabbixproxy {
	$zabbixRPMPubkey = "<location of public key on local machine>"
	$zabbix_server = "<IP address or DNS name of zabbix server>"
	$zabbix_proxy_config_dir = "/etc/zabbix"
	$zabbix_proxy_conf = "$zabbix_proxy_config_dir/zabbix_proxy.conf"
	$zabbix_proxy_log_dir = "/var/log/zabbix/"
	$zabbix_proxy_pid_dir = "/var/run/zabbix/"
	
	# Retrieves and imports Zabbix Public key
   	exec {
		"getPublicKey":
        		command         =>		"wget <public key location online> && rpm --import $zabbixRPMPubkey ",
                cwd             =>		"/etc/pki/rpm-gpg/",
                creates         =>		"$zabbixRPMPubkey",
                path            =>		"/usr/bin/:/bin/"
		}

   group {
		"zabbix":
                ensure          =>		present;
		}

    user {
		"zabbix":
                ensure          =>		present,
                gid             =>		zabbix,
                membership		=>		minimum,
                shell           =>		"/sbin/nologin",
                home            =>		"/var/lib/zabbix",
                require         =>		Group["zabbix"]
		}

    file {
		$zabbixRPMPubkey:
            ensure				=>		present,
            owner				=>		'root',
            group				=>		'root',
            mode        		=>		'0644',
            require     		=>		Exec['getPublicKey'];
	
	 	$zabbix_proxy_config_dir:
            ensure				=>		directory,
            owner				=>		'root',
            group				=>		'root',
            mode        		=>		'0755',
        	require     		=>		Package["zabbix-proxy"];
	
		$zabbix_proxy_conf:
            owner				=>		'root',
            group				=>		'root',
            mode        		=>		'0640',
            content     		=>		template("zabbixagent/zabbix_proxy_conf.erb"),
            require     		=>		Package["zabbix-proxy"]
		  
		$zabbix_proxy_log_dir:
			ensure				=>		directory,
			owner				=>		'zabbix',
			group				=>		'zabbix',
			mode				=>		'0755',
			require				=>		Package["zabbix-proxy"];
		
		$zabbix_proxy_pid_dir:
            ensure 				=> 		directory,
            owner 				=> 		'zabbix',
            group 				=> 		'zabbix',
            mode 				=> 		'0755',
            require 			=> 		Package["zabbix-agent"];		
		}

	package {
		"zabbix-agent":
            ensure				=>		installed,
            require				=>		Exec["getPublicKey"]
		
		"mysql":
			ensure				=>		installed,
			} 
		
 	service {
        "zabbix-proxy":
            enable				=> 		true,
            ensure 				=> 		running,
            hasstatus 			=> 		true,
            hasrestart 			=>		true,
            require 			=> 		Package["zabbix-proxy", "mysql"]
    	
    	"mysql":
    		enable				=>		true,
    		ensure				=>		running,
    		hasstatus			=>		true,
    		hasrestart			=>		true,
    		require				=>		Package["mysql"]
    }
}
	