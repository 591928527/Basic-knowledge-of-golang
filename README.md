# golang常见的数据结构实现原理
## 1. chan
   channel是Golang在语言层面提供的goroutine间的通信方式，比Unix管道更易用也更轻便。channel主要用于进程内各goroutine间通信，如果需要跨进程通信，建议使用分布式系统的方法来解决。

## 1.1 chan数据结构
###  1.1.1 src/runtime/chan.go:hchan定义了channel的数据结构：

  type hchan struct {  
    &emsp; qcount   uint               &emsp;&emsp;&emsp;&emsp;  // 当前队列中剩余元素个数  
    &emsp; dataqsiz uint               &emsp;&emsp;&emsp;&emsp;  // 环形队列长度，即可以存放的元素个数  
    &emsp; buf      unsafe.Pointer     &emsp;&emsp;&emsp;&emsp;  // 环形队列指针  
    &emsp; elemsize uint16             &emsp;&emsp;&emsp;&emsp;  // 每个元素的大小  
    &emsp; closed   uint32             &emsp;&emsp;&emsp;&emsp;  // 标识关闭状态  
    &emsp; elemtype *_type             &emsp;&emsp;&emsp;&emsp;  // 元素类型  
    &emsp; sendx    uint               &emsp;&emsp;&emsp;&emsp;  // 队列下标，指示元素写入时存放到队列中的位置  
    &emsp; recvx    uint               &emsp;&emsp;&emsp;&emsp;  // 队列下标，指示元素从队列的该位置读出  
    &emsp; recvq    waitq              &emsp;&emsp;&emsp;&emsp;  // 等待读消息的goroutine队列  
    &emsp; sendq    waitq              &emsp;&emsp;&emsp;&emsp;  // 等待写消息的goroutine队列  
    &emsp; lock mutex                  &emsp;&emsp;&emsp;&emsp;  // 互斥锁，chan不允许并发读写  
 }

### 1.1.2  环形队列
   chan内部实现了一个环形队列作为其缓冲区，队列的长度是创建chan时指定的。通过make(chan int,number)

   下图展示了一个可缓存6个元素的channel示意图：
    ![image](chan-01-circle_queue.png)

    dataqsiz指示了队列长度为6，即可缓存6个元素；  
    buf指向队列的内存，队列中还剩余两个元素；  
    qcount表示队列中还有两个元素；  
    sendx指示后续写入的数据存储的位置，取值[0, 6)；  
    recvx指示从该位置读取数据, 取值[0, 6)；  

### 1.1.3  等待队列
   从channel读数据，如果channel缓冲区为空或者没有缓冲区，当前goroutine会被阻塞。向channel写数据，如果channel缓冲区已满或者没有缓冲区，当前goroutine会被阻塞。  

   被阻塞的goroutine将会挂在channel的等待队列中：
     因读阻塞的goroutine会被向channel写入数据的goroutine唤醒；  
     因写阻塞的goroutine会被从channel读数据的goroutine唤醒；  

   下图展示了一个没有缓冲区的channel，有几个goroutine阻塞等待读数据： 
   ![image](chan-02-wait_queue.png) 

   注意，一般情况下recvq和sendq至少有一个为空。只有一个例外，那就是同一个goroutine使用select语句向channel一边写数据，一边读数据。