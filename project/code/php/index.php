<?php

require 'lock.php';
$redis = new Redis();
$redis->connect("127.0.0.1", 6379);
//$redis->auth("sixstar");
$redis = new Lock($redis);
$key = 'key';
$res = $redis->lock($key, 3, 1, 10); //等待获取锁
if ($res) {
    sleep(5); //业务逻辑
    //比对时间版本,看哪个比较新
    var_dump("执行任务");
    $redis->unlock($key);
    return;
}





