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