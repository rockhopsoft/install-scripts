#!/bin/bash

# To be run under sudo su...

echo '================================================'
echo 'Installing Wazuh Agent on CloudPanel Part 2 of 2'
echo '------------------------------------------------'

echo 'Copy this chunk of code and paste in the bottom of ossec.conf:'
echo ''
#echo '  <localfile>
#    <log_format>syslog</log_format>
#    <location>/var/log/clamav/clamav.log</location>
#  </localfile>
#  <localfile>
#    <log_format>syslog</log_format>
#    <location>/var/log/clamav/freshclam.log</location>
#  </localfile>'
echo '<ossec_config>
  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
</ossec_config>'
echo ''
echo '---'

read -p $'Have you copied the above code?\n(Y)\n' COPIED
echo ''

set -x

nano /var/ossec/etc/ossec.conf
systemctl daemon-reload && systemctl enable wazuh-agent && systemctl start wazuh-agent



echo ''
echo 'Integrating ClamAV'
echo '------------------'
echo 'https://documentation.wazuh.com/current/user-manual/capabilities/malware-detection/clam-av-logs-collection.html'
echo ''


echo 'Integrating Suricata'
echo '--------------------'
echo 'https://documentation.wazuh.com/current/proof-of-concept-guide/integrate-network-ids-suricata.html'
echo ''
cd /tmp/ && curl -LO https://rules.emergingthreats.net/open/suricata-6.0.8/emerging.rules.tar.gz
tar -xvzf emerging.rules.tar.gz && mkdir /etc/suricata/rules && mv rules/*.rules /etc/suricata/rules/
chmod 640 /etc/suricata/rules/*.rules
echo ''
