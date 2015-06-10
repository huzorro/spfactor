package sexredis

import (
	"errors"
	"github.com/gosexy/redis"
)

//  Example use
//	q := sexredis.New()
//	q.Create("myqueue", "localhost", uint(6379))
//	for i := 0; i < 5; i++ {
//		q.Put(mjson)
//	}

//	q.Worker(uint(5), func(msg string, err error) {
//		if err != nil {
//			log.Printf(err.Error())
//		} else {
//			log.Printf("... %s\n", msg)
//		}

//	})
type Queue struct {
	Name    string
	Rc      *redis.Client
	Msgchan chan Msg
}

type Msg struct {
	Content interface{}
	Err     error
}

type Processor interface {
	SProcess(msg *Msg)
}

func New() *Queue {
	q := new(Queue)
	return q
}

func (self *Queue) SetRClient(name string, rc *redis.Client) {
	self.Name = name
	self.Rc = rc
}

func (self *Queue) Create(name string, host string, port uint) error {
	self.Name = name
	self.Rc = redis.New()
	return self.Rc.Connect(host, port)
}

func (self *Queue) Active() (response string, err error) {
	return self.Rc.Ping()
}

func (self *Queue) LLen() (l int64, err error) {
	return self.Rc.LLen(self.Name)
}

func (self *Queue) Keys() (name string) {
	return self.Name
}

func (self *Queue) Clear() (recode int64, err error) {
	return self.Rc.Del(self.Name)
}

func (self *Queue) Close() (string, error) {
	return self.Rc.Quit()
}

func (self *Queue) Get(block bool, timeout uint64) (msg Msg) {
	if block {
		if rs, err := self.Rc.BLPop(timeout, self.Name); err != nil {
			return Msg{"", err}
		} else {
			if len(rs) > 1 {
				return Msg{rs[1], nil}
			} else {
				return Msg{"", errors.New("queue is empty")}
			}
		}
	} else {
		m, err := self.Rc.LPop(self.Name)
		return Msg{m, err}
	}
}

func (self *Queue) Put(msg interface{}) (recode int64, err error) {
	return self.Rc.RPush(self.Name, msg)
}

/*
use channel implement like python yield
*/
func (self *Queue) Consume() {
	self.Msgchan = make(chan Msg)
	for {
		//		if msg, err := self.Get(true, uint64(0)); err != nil {
		//			return err
		//		} else {
		//			self.msgchan <- msg
		//		}

		self.Msgchan <- self.Get(true, uint64(0))
	}
}

func (self *Queue) Yield() (msg Msg) {
	return <-self.Msgchan
}

//func (self *Queue) Worker(pnum uint, fn func(msg string, err error)) {
//	var err error
//	control := make(chan string, pnum)
//	go func() {
//		self.consume()
//	}()

//	go func() {
//		for {
//			if err != nil {
//				fn("", err)
//				return
//			}
//			msg := self.yield()
//			control <- msg
//			go func() {
//				fn(msg, nil)
//				<-control
//			}()
//		}
//	}()
//}

func (self *Queue) Worker(pnum uint, serial bool, ps ...Processor) {
	control := make(chan Msg, pnum)
	go func() {
		self.Consume()
	}()

	go func() {
		for {
			msg := self.Yield()
			control <- msg
			go func() {
				if serial {
					for _, sp := range ps {
						sp.SProcess(&msg)
						if msg.Err != nil {
							break
						}
					}
				} else {
					//并行处理
				}
				<-control
			}()
		}
	}()
}
