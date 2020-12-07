<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/11/20
 * Time: 22:46
 */
class  Lock{
    protected  $redis;
    private   $lock_id;
    public function __construct($redis)
    {
        $this->redis=$redis;
    }

    public  function lock($key,$retry=2,$timeout=1,$ex=10){
        $ok=false;
        $value=session_create_id();
        while ( $retry-- ){
            $ok=$this->redis->set($key,$value,['nx','ex'=>$ex]);
            if($ok){
                $this->lock_id[$key]=$value;
                break;
            }
            sleep(1); //阻塞进程的
            var_dump("等待获取锁");
        }
        return $ok;
    }

    public  function unlock($key){
        //直接删除key了
        if(isset($this->lock_id[$key])){
            $lock=$this->lock_id[$key];
            if($this->redis->get($key) == $lock){
                return $this->redis->delete($key);
            }
        }
        return false;

    }

}



