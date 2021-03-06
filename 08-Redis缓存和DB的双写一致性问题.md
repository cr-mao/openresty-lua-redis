## Redis缓存和DB的一致性问题

#### 产生原因

主要有两种情况，会导致缓存和 DB 的一致性问题：

缓存和 DB 的操作，不在一个事务中，可能只有一个操作成功，而另一个操作失败，导致不一致。

我们讨论二种更新策略：

- 先更新数据库，再更新缓存
- 先删除缓存，再更新数据库



（1)先更新数据库，再更新缓存 这套方案，我们不考虑

问题:同时有请求A和请求B进行更新操作，那么会出现

- （1）A更新了数据库
- （2）B更新了数据库
- （3）B更新了缓存
- （4）A更新了缓存

这就出现请求A更新缓存应该比请求B更新缓存早才对，但是因为网络等原因，B却比A更早更新了缓存。这就导致了脏数据

 (2)先删缓存，再更新数据库

我们会基于这个方案去实现缓存更新，但是不代表这个方案在并发情况下没问题

该方案会导致不一致的原因是。同时有一个请求A进行更新操作，另一个请求B进行查询操作。那么会出现如下情形:

- （1）请求A进行写操作，删除缓存
- （2）请求B查询发现缓存不存在
- （3）请求B去数据库查询得到旧值
- （4）请求B将旧值写入缓存
- （5）请求A将新值写入数据库
  上述情况就会导致不一致的情形出现

#### 解决方案（数据库与缓存更新与读取操作进行异步串行化）

更新数据的时候，将操作任务，发送到一个队列中。读取数据的时候，如果发现数据不在缓存中，那么将重新读取数据+更新缓存的操作任务，也发送同一个
队列中。 每个队列可以对应多个消费者，每个队列拿到对应的消费者，然后一条一条的执行



### Cache Aside Pattern

最经典的缓存+数据库读写的模式，就是 Cache Aside Pattern。

读的时候，先读缓存，缓存没有的话，就读数据库，然后取出数据后放入缓存，同时返回响应。更新的时候，先更新数据库，然后再删除缓存。