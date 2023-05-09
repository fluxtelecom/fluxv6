1. Enable nibble billing in modules.conf
2. Replace mod_niblebill.c with the attached mod_nibblebill.c
3. Change nibblebill.conf accordingly with your database user and password(only change database name and user and password)
4. Compile and install freeswitch
5. replace flux.xml.lua and flux.dialplan.lua with provided attached file in /usr/local/freeswitch/scripts/flux/scripts
6. replace /var/www/html/fs/lib/flux.cdr.php with provided attached file flux.cdr.php
7. Start freeswitch and load mod_nibblebill.
