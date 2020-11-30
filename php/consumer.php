<?php

require  'unique.php';

ini_set("default_socket_timeout",-1); //socket连接不超时
$redis=new \RedisCluster(null,["192.168.1.2:6420","192.168.1.3:6421","192.168.1.4:6422","192.168.1.5:6423","192.168.1.6:6424","192.168.1.7:6425"],$timeout = null,0, true,"");
$unique=new Unique($redis);
//一次性做两个操作,要么都成功,要么都不要成功,用lua脚本 (redis集群环境)
$setName="{queue_1_20000}:update_queue";  //集合key
try{
    while (true){
        $data=$unique->redis->SMembers($setName);
        if(!empty($data)){
            foreach ($data as $queueName){
                $jobData=$unique->pop($setName,$queueName);
                if (!empty($jobData)){
                    $job=json_decode($jobData,true);
                    //mysql IO 操作
                    switch ($job['method']){
                        case  'updateCacheImage':
                            //从数据库当中取出数据,写入到缓存当中
                            sleep(0.2);
                            if($unique->redis->set('product_image_'.$job['data']['id'],"images:".$job['data']['id'])){
                                echo "缓存更新成功";
                            }else{
                                throw  new Exception("fail");
                            }
                            break;
                    }

                }
            }
        }
        usleep(100000);
    }
}catch (Exception $e){
    //连接重试

    //作业
    if ($e->getMessage()=='fail'){
        //记录日志,记录尝试次数
    }
    //或者说再次调用push,写到任务队列当中

}






//;
