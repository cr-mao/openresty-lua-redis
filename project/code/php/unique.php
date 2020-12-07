<?php

class  Unique
{

    // SADD保证只有一个 任务如商品id=1的 更新缓存的任务
    // return redis.call("LPUSH",jobName,ARGV[2])       =》  LPUSH  更新商品id的任务   对应的操作
    const  PUSH = '
          local setName=KEYS[1]
          local jobName=ARGV[1]
          local res=redis.call("SADD",setName,jobName)
          if res == 1 then 
             return redis.call("LPUSH",jobName,ARGV[2])
          end
          return 0
    ';

    //SREM 失败 代码 ?
    const  POP = '
          local setName=KEYS[1]
          local jobName=ARGV[1]
          local res=redis.call("RPOP",jobName)
          if type(res) == "boolean" then 
             return 0
          end
          if redis.call("SREM",setName,jobName) then
            return res
          else
            return 0
          end
    ';


    public function __construct($redis)
    {
        $this->redis = $redis;
    }


    public function push($setName, $queueName, $jobData)
    {

        return $this->redis->eval(self::PUSH, [$setName, $queueName, $jobData], 1);
//        if($this->redis->sAdd($setName,$queueName)){
//            return $this->redis->lpush($queueName,$job);
//        }
//        return false;
    }

    public function pop($setName, $jobName)
    {
        return $this->redis->eval(self::POP, [$setName, $jobName], 1);
    }


}
