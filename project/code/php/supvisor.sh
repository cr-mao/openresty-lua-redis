active=`ps aux|grep consumer\.php|grep -v grep | wc -l`
if [ $active == 0 ];then
    /usr/local/php  /var/www/consumer.php
fi