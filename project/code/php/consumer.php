<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/11/29
 * Time: 22:31
 */

require  'unique.php';

ini_set("default_socket_timeout",-1); //socket连接不超时
$redis=new \RedisCluster(null,["118.24.109.254:6390","118.24.109.254:6391","118.24.109.254:6392","118.24.109.254:6393"],$timeout = null,0, true,"sixstar");
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
