<?php

require 'unique.php';
$data = $_GET;

$redis = new \RedisCluster(null, ["192.168.1.2:6420", "192.168.1.3:6421", "192.168.1.4:6422", "192.168.1.5:6423", "192.168.1.6:6424", "192.168.1.7:6425"], $timeout = null, $readTimeout = null, $persistent = false);
$config = [
    '1_20000' => '{queue_1_20000}',
    '200000_40000' => '{queue_20000_40000}'
];
//一次性做两个操作,要么都成功,要么都不要成功,用lua脚本 (redis集群环境)
$setName = "{queue_1_20000}:update_queue";  //集合key
$queueName = "{queue_1_20000}:product_image_10";  //
try {
    //先判断当前的id是否有更新任务，没有再添加，如果有更新任务了，等待获取
    $unique = new Unique($redis);
    flag:
    $res = $unique->redis->sIsMember($setName, $queueName);
    $retry = 3;
    $sleep = 1;
    if ($res) {
        //等待任务完成返回结果，查询是否有数据
        while ($retry--) {
            $ok = $unique->redis->get("product_image_" . $data['id']);
            if ($ok) {
                echo $ok . PHP_EOL;
                break;
            }
            sleep($sleep); //不希望阻塞进程的（协程）
            var_dump("等待获取数据");
        }
    } else {
        $job = json_encode(["method" => "updateCacheImage", "data" => ["id" => $data['id']]]);
        if ($unique->push($setName, $queueName, $job)) {
            echo "更新缓存的任务添加成功" . PHP_EOL;
            goto flag;
        }
        //第一次任务放入到队列当中，并没有获取结果
    }

} catch (Exception $e) {

}


//弹出任务
//var_dump($unique->pop($setName,$queueName));